import { spawnSync } from "node:child_process";
import { constants } from "node:fs";
import {
  access,
  chmod,
  copyFile,
  lstat,
  mkdir,
  mkdtemp,
  readFile,
  rename,
  rm,
  stat,
  writeFile,
} from "node:fs/promises";
import { homedir, tmpdir } from "node:os";
import { dirname, join, resolve } from "node:path";
import { createInterface } from "node:readline/promises";
import { pathToFileURL } from "node:url";

const USAGE = `Usage: ./update-config.sh [--config PATH] [--dry-run]

Adds missing values from recommended-config.toml to the Codex configuration.
Existing values are preserved and reported when they differ from a recommendation.`;

function parseArguments(arguments_) {
  let configPath = join(homedir(), ".codex", "config.toml");
  let dryRun = false;

  for (let index = 0; index < arguments_.length; index += 1) {
    const argument = arguments_[index];

    if (argument === "--config") {
      const value = arguments_[index + 1];
      if (!value) throw new Error("--config requires a path");
      configPath = resolve(value);
      index += 1;
    } else if (argument === "--dry-run") {
      dryRun = true;
    } else if (argument === "--help" || argument === "-h") {
      console.log(USAGE);
      process.exit(0);
    } else {
      throw new Error(`Unknown argument: ${argument}`);
    }
  }

  return { configPath, dryRun };
}

function isTable(value) {
  return (
    value !== null &&
    typeof value === "object" &&
    !Array.isArray(value) &&
    !(value instanceof Date)
  );
}

function tomlValuesEqual(left, right) {
  if (Object.is(left, right)) return true;
  if (typeof left !== typeof right || left === null || right === null) return false;
  if (left instanceof Date || right instanceof Date) {
    return (
      left.constructor === right.constructor && left.toString() === right.toString()
    );
  }
  if (Array.isArray(left) || Array.isArray(right)) {
    return (
      Array.isArray(left) &&
      Array.isArray(right) &&
      left.length === right.length &&
      left.every((value, index) => tomlValuesEqual(value, right[index]))
    );
  }
  if (typeof left !== "object") return false;

  const leftKeys = Object.keys(left);
  const rightKeys = Object.keys(right);
  return (
    leftKeys.length === rightKeys.length &&
    leftKeys.every(
      (key) => Object.hasOwn(right, key) && tomlValuesEqual(left[key], right[key]),
    )
  );
}

function cloneRecommendation(value) {
  if (!isTable(value)) return value;

  return Object.fromEntries(
    Object.entries(value).map(([key, child]) => [key, cloneRecommendation(child)]),
  );
}

function mergeMissing(existing, recommended, conflicts, path = []) {
  for (const [key, recommendedValue] of Object.entries(recommended)) {
    const nextPath = [...path, key];

    if (!Object.hasOwn(existing, key)) {
      existing[key] = cloneRecommendation(recommendedValue);
      continue;
    }

    const existingValue = existing[key];
    if (isTable(existingValue) && isTable(recommendedValue)) {
      mergeMissing(existingValue, recommendedValue, conflicts, nextPath);
    } else if (!tomlValuesEqual(existingValue, recommendedValue)) {
      conflicts.push(nextPath.join("."));
    }
  }
}

async function fileExists(path) {
  try {
    await access(path, constants.F_OK);
    return true;
  } catch {
    return false;
  }
}

async function assertSafeTarget(configPath) {
  if (!(await fileExists(configPath))) return;

  const metadata = await lstat(configPath);
  if (metadata.isSymbolicLink()) {
    throw new Error(`Refusing to replace symbolic link: ${configPath}`);
  }
  if (!metadata.isFile()) {
    throw new Error(`Configuration path is not a regular file: ${configPath}`);
  }
}

async function showDiff(configPath, existingSource, candidateSource) {
  const temporaryDirectory = await mkdtemp(join(tmpdir(), "codex-config-update-"));
  const currentPath = join(temporaryDirectory, "current.toml");
  const proposedPath = join(temporaryDirectory, "proposed.toml");

  try {
    await Promise.all([
      writeFile(currentPath, existingSource, "utf8"),
      writeFile(proposedPath, candidateSource, "utf8"),
    ]);

    console.log(`\nProposed changes to ${configPath}:\n`);
    const result = spawnSync(
      "diff",
      [
        "-u",
        "--label",
        `${configPath} (current)`,
        "--label",
        `${configPath} (proposed)`,
        currentPath,
        proposedPath,
      ],
      { encoding: "utf8" },
    );

    if (result.error) throw result.error;
    if (result.status !== 0 && result.status !== 1) {
      throw new Error(result.stderr.trim() || "Unable to generate configuration diff");
    }

    process.stdout.write(result.stdout);
  } finally {
    await rm(temporaryDirectory, { recursive: true, force: true });
  }
}

function timestamp() {
  return new Date().toISOString().replaceAll(":", "-").replace(/\.\d{3}Z$/, "Z");
}

async function confirmUpdate() {
  if (!process.stdin.isTTY || !process.stdout.isTTY) {
    throw new Error(
      "An interactive terminal is required for consent. Use --dry-run to preview only.",
    );
  }

  const prompts = createInterface({ input: process.stdin, output: process.stdout });
  try {
    const answer = await prompts.question("\nApply these changes? [y/N] ");
    return ["y", "yes"].includes(answer.trim().toLowerCase());
  } finally {
    prompts.close();
  }
}

async function main() {
  const { configPath, dryRun } = parseArguments(process.argv.slice(2));
  const recommendationPath = process.env.CODEX_RECOMMENDED_CONFIG;
  const tomlModulePath = process.env.TOML_PATCH_MODULE;

  if (!recommendationPath || !tomlModulePath) {
    throw new Error("Run this helper through ./update-config.sh");
  }

  await assertSafeTarget(configPath);

  const configExists = await fileExists(configPath);
  const [existingSource, recommendedSource] = await Promise.all([
    configExists ? readFile(configPath, "utf8") : "",
    readFile(recommendationPath, "utf8"),
  ]);
  const TOML = await import(pathToFileURL(tomlModulePath).href);
  const recommended = TOML.parse(recommendedSource);
  const existing = TOML.parse(existingSource);
  const conflicts = [];

  mergeMissing(existing, recommended, conflicts);

  const format = TOML.TomlFormat.autoDetectFormat(existingSource);
  format.inlineTableStart = Number.POSITIVE_INFINITY;
  const candidateSource = configExists
    ? TOML.patch(existingSource, existing, format)
    : recommendedSource;
  const parsedCandidate = TOML.parse(candidateSource);
  if (!tomlValuesEqual(parsedCandidate, existing)) {
    throw new Error("Generated configuration did not pass semantic TOML validation");
  }

  if (conflicts.length > 0) {
    console.log("Existing values kept instead of these recommendations:");
    for (const conflict of conflicts) console.log(`  - ${conflict}`);
  }

  if (candidateSource === existingSource) {
    console.log(`Already up to date: ${configPath}`);
    return;
  }

  await showDiff(configPath, existingSource, candidateSource);
  if (dryRun) {
    console.log("\nDry run only; no files changed.");
    return;
  }

  if (!(await confirmUpdate())) {
    console.log("No changes made.");
    return;
  }

  const configExistsNow = await fileExists(configPath);
  if (configExistsNow !== configExists) {
    throw new Error("Configuration changed after the preview; rerun the updater");
  }

  await assertSafeTarget(configPath);
  const latestSource = configExistsNow ? await readFile(configPath, "utf8") : "";
  if (latestSource !== existingSource) {
    throw new Error("Configuration changed after the preview; rerun the updater");
  }

  await mkdir(dirname(configPath), { recursive: true });

  let backupPath;
  let mode = 0o600;
  if (configExists) {
    mode = (await stat(configPath)).mode & 0o777;
    backupPath = `${configPath}.backup-${timestamp()}`;
    await copyFile(configPath, backupPath, constants.COPYFILE_EXCL);
  }

  const temporaryPath = join(dirname(configPath), `.config.toml.update-${process.pid}`);
  try {
    await writeFile(temporaryPath, candidateSource, {
      encoding: "utf8",
      flag: "wx",
      mode,
    });
    await chmod(temporaryPath, mode);
    await rename(temporaryPath, configPath);
  } catch (error) {
    await rm(temporaryPath, { force: true });
    throw error;
  }

  console.log(`Updated: ${configPath}`);
  if (backupPath) console.log(`Backup: ${backupPath}`);
  console.log("Restart Codex to ensure all new settings are loaded.");
}

main().catch((error) => {
  console.error(`Error: ${error.message}`);
  process.exitCode = 1;
});
