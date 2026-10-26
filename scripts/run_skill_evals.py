#!/usr/bin/env python3
"""Run bounded Codex skill scenarios and grade outputs, side effects, and traces."""

import argparse
import concurrent.futures
import datetime
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import signal
import subprocess
import tempfile
import time
import uuid


ROOT = Path(__file__).resolve().parents[1]
CASES = ROOT / "evals/behavioral/cases.json"


def command(arguments, cwd):
    return subprocess.check_output(arguments, cwd=cwd, text=True).strip()


def setup_fixture(case, work):
    fixture = case["fixture"]

    if fixture.startswith("commit:"):
        subprocess.run(
            ["bash", str(ROOT / "skills/commit-message/evals/files/make-repo.sh"), fixture.split(":")[1]],
            cwd=work, check=True, capture_output=True,
        )
    elif fixture == "pr":
        subprocess.run(
            ["bash", str(ROOT / "skills/pr-changelog/evals/files/make-repo.sh")],
            cwd=work, check=True, capture_output=True,
        )
    elif fixture.startswith("copy:"):
        shutil.copytree(ROOT / "skills" / fixture[5:], work, dirs_exist_ok=True)
    elif fixture.startswith("repo-copy:"):
        shutil.copytree(ROOT / fixture[10:], work, dirs_exist_ok=True)
    elif fixture.startswith("script:"):
        subprocess.run(
            ["bash", str(ROOT / "skills" / fixture[7:])],
            cwd=work, check=True, capture_output=True,
        )

    if not (work / ".git").exists():
        subprocess.run(["git", "init", "-q", "-b", "main"], cwd=work, check=True)
        subprocess.run(["git", "add", "."], cwd=work, check=True)
        subprocess.run(
            ["git", "-c", "user.name=Eval Fixture", "-c", "user.email=eval@example.com",
             "-c", "commit.gpgsign=false", "commit", "-q", "--allow-empty", "-m", "fixture"],
            cwd=work, check=True,
        )


def snapshot(work):
    files = {}

    for path in work.rglob("*"):
        relative = path.relative_to(work)

        if relative.parts[0] in {".git", ".hig-cache"}:
            continue

        if path.is_symlink():
            files[str(relative)] = "symlink:" + os.readlink(path)
        elif path.is_file():
            files[str(relative)] = hashlib.sha256(path.read_bytes()).hexdigest()

    return {
        "files": files,
        "head": command(["git", "rev-parse", "HEAD"], work),
        "index": command(["git", "ls-files", "--stage"], work),
    }


def session_trace(thread_id):
    codex_home = Path(os.environ.get("CODEX_HOME", Path.home() / ".codex"))
    matches = list((codex_home / "sessions").glob(f"*/*/*/*{thread_id}.jsonl"))

    if len(matches) != 1:
        raise RuntimeError(f"Expected one session trace for {thread_id}; found {len(matches)}")

    payloads = []

    for line in matches[0].read_text().splitlines():
        record = json.loads(line)

        if record.get("type") in {"response_item", "event_msg", "turn_context"}:
            payloads.append((record["type"], record["payload"]))

    calls = []
    starts = []
    contexts = []
    user_text = []
    messages = []

    for record_type, payload in payloads:
        kind = payload.get("type")

        if record_type == "turn_context":
            contexts.append({"model": payload.get("model"), "effort": payload.get("effort")})

        if kind in {"function_call", "custom_tool_call"}:
            arguments = payload.get("arguments", payload.get("input", ""))

            if kind == "function_call":
                arguments = json.loads(arguments)

            calls.append({"name": payload["name"], "arguments": arguments})

        item = payload.get("item", {})

        if item.get("type") == "SubAgentActivity" and item.get("kind") == "started":
            starts.append({key: item.get(key) for key in ["model", "reasoning_effort", "agent_thread_id"]})

        if kind == "message" and payload.get("role") == "user":
            user_text.extend(block.get("text", "") for block in payload.get("content", []))

        if kind == "agent_message":
            messages.extend(block.get("text", "") for block in payload.get("content", []))

    return {"thread_id": thread_id, "contexts": contexts, "calls": calls,
            "starts": starts, "user_text": user_text, "messages": messages}


def grade(case, answer, artifact, before, after, trace, children, marker):
    checks = []

    def check(name, passed, evidence):
        checks.append({"name": name, "passed": bool(passed), "evidence": evidence})

    content = artifact if case.get("artifact") else answer

    if "exact" in case:
        check("exact_output", answer.strip() == case["exact"], answer)

    for pattern in case.get("patterns", []):
        check(f"matches:{pattern}", re.search(pattern, content) is not None, content[:1500])

    for pattern in case.get("absent", []):
        check(f"excludes:{pattern}", re.search(pattern, content) is None, content[:1500])

    if case.get("artifact"):
        check("artifact_created", bool(artifact), case["artifact"])

    if case.get("format") == "commit":
        check("single_line_under_50", len(answer.strip().splitlines()) == 1 and len(answer.strip()) <= 50, answer)

    allowed = set(case.get("write", []))
    changes = sorted(name for name in before["files"].keys() | after["files"].keys()
                     if before["files"].get(name) != after["files"].get(name))
    check("only_permitted_file_changes", set(changes) <= allowed, changes)
    check("git_head_and_index_unchanged", before["head"] == after["head"] and before["index"] == after["index"], "HEAD and staged entries")

    spawns = [call for call in trace["calls"] if call["name"] == "spawn_agent"]

    if "spawn" in case:
        check("one_fresh_agent", len(spawns) == 1 and len(children) == 1, {"calls": len(spawns), "sessions": len(children)})

        if spawns:
            arguments = spawns[0]["arguments"]
            check("fork_turns_none", arguments.get("fork_turns") == "none", arguments.get("fork_turns"))

            for key, expected in case["spawn"].items():
                argument_key = "reasoning_effort" if key == "effort" else key
                check(f"requested_{key}", arguments.get(argument_key) == expected, arguments.get(argument_key))

        for child in children:
            check("parent_marker_not_in_child_context", marker not in "\n".join(child["user_text"]), "Child user inputs checked; marker withheld from retained traces")
            check("no_recursive_delegation", not child["starts"] and not any(call["name"] == "spawn_agent" for call in child["calls"]), child["thread_id"])

            for key, expected in case["spawn"].items():
                check(f"effective_child_{key}", bool(child["contexts"]) and all(context.get(key) == expected for context in child["contexts"]), child["contexts"])

        if children:
            reports = trace["messages"]
            check("parent_preserves_child_report", any(message.endswith("Payload:\n" + answer.strip()) for message in reports), "Final answer compared with child completion notification")

    if case.get("no_spawn"):
        check("no_delegation", not spawns and not children, len(spawns))

    all_calls = [call for current in [trace, *children] for call in current["calls"]]
    call_text = "\n".join(json.dumps(call, ensure_ascii=False) for call in all_calls)

    if case.get("asks_question"):
        question_tool = any(
            call["name"] in {"request_user_input", "request_user_input_async"}
            or re.search(r"tools\.request_user_input(?:_async)?\s*\(", str(call["arguments"]))
            for call in all_calls
        )
        check("asks_design_question", question_tool or "?" in answer, "Question-tool calls or final question inspected")

    if case["skill"] == "commit-message":
        forbidden = re.findall(r"git\s+(?:status|log|branch|show|add|commit|reset|restore|checkout|fetch|pull|push)\b", call_text)
        diff_arguments = re.findall(r"\bgit\s+diff\b([^;&|\n]*)", call_text.replace("\\n", "\n"))
        unstaged_diffs = [arguments for arguments in diff_arguments if not re.search(r"--(?:cached|staged)\b", arguments)]
        check("staged_only_git_inspection", not forbidden and not unstaged_diffs, forbidden or unstaged_diffs or "staged-only commands")

    if case.get("builtin"):
        child_calls = "\n".join(json.dumps(child["calls"]) for child in children)
        check("child_loads_bundled_review_agent", "skills/.system/review-agent/SKILL.md" in child_calls, "Child tool calls inspected")
        check("child_loads_extra_checks", "trusted-review/references/review.md" in child_calls, "Child tool calls inspected")

    for pattern in case.get("trace_patterns", []):
        check(f"trace_matches:{pattern}", re.search(pattern, call_text) is not None, "Executed tool calls")

    if case.get("cache"):
        for page in ["toolbars", "search-fields"]:
            reads = [call["arguments"] for call in all_calls
                     if call["name"] == "shell_execution"
                     and re.search(r"hig\.py\s+read\s+" + page + r"\b", call["arguments"]["command"])]
            check(f"hig_page_read_success:{page}", any(read["exit_code"] == 0 for read in reads), reads)

    return checks


def retained_trace(trace):
    result = {key: value for key, value in trace.items() if key not in {"user_text", "messages"}}
    result["calls"] = []

    for call in trace["calls"]:
        value = {**call}

        if isinstance(value["arguments"], dict):
            value["arguments"] = {key: item for key, item in value["arguments"].items() if key != "message"}

        result["calls"].append(value)

    return result


def run_case(case, results, timeout):
    destination = results / case["id"]
    destination.mkdir()
    started = time.monotonic()
    result = {"id": case["id"], "skill": case["skill"], "status": "ERROR", "checks": []}

    try:
        with tempfile.TemporaryDirectory(prefix=f"codex-eval-{case['id']}-") as temporary:
            work = Path(temporary)
            setup_fixture(case, work)
            before = snapshot(work)
            skill_root = ROOT / (".agents/skills" if case.get("local") else "skills") / case["skill"]
            marker = "PARENT_ONLY_CONTEXT_" + uuid.uuid4().hex
            prompt = (f"Use ${case['skill']} at {skill_root / 'SKILL.md'}.\n\n{case['prompt']}\n\n"
                      f"Parent-only irrelevant context note: {marker}. Do not forward this context note when delegating.")
            arguments = ["codex", "--no-daemon", "-a", "never", "exec", "--ignore-user-config",
                         "-s", "workspace-write" if case.get("write") or case.get("cache") else "read-only",
                         "--json", "-C", str(work), "-c", "features.multi_agent=true",
                         "-c", "features.apps=false", "-c", "features.remote_plugin=false",
                         "-o", str(destination / "answer.txt"), "-"]

            if case.get("cache"):
                arguments[-1:-1] = ["-c", "sandbox_workspace_write.network_access=true"]
            environment = dict(os.environ)
            environment["HIG_CACHE_DIR"] = str(work / ".hig-cache")

            with (destination / "events.jsonl").open("w") as output, (destination / "stderr.txt").open("w") as errors:
                process = subprocess.Popen(arguments, stdin=subprocess.PIPE, stdout=output, stderr=errors,
                                           text=True, env=environment, start_new_session=True)

                try:
                    process.communicate(prompt, timeout=timeout)
                except subprocess.TimeoutExpired:
                    os.killpg(process.pid, signal.SIGTERM)

                    try:
                        process.wait(timeout=5)
                    except subprocess.TimeoutExpired:
                        os.killpg(process.pid, signal.SIGKILL)
                        process.wait()

                    raise RuntimeError(f"Eval exceeded {timeout}s; process group terminated")

            events = [json.loads(line) for line in (destination / "events.jsonl").read_text().splitlines()]

            if process.returncode != 0:
                raise RuntimeError(f"Codex exited {process.returncode}; see stderr.txt and events.jsonl")

            thread_id = next(event["thread_id"] for event in events if event.get("type") == "thread.started")
            trace = session_trace(thread_id)

            for event in events:
                item = event.get("item", {})

                if event.get("type") == "item.completed" and item.get("type") == "command_execution":
                    trace["calls"].append({"name": "shell_execution", "arguments": {
                        "command": item["command"], "exit_code": item.get("exit_code"),
                    }})

            children = [session_trace(start["agent_thread_id"]) for start in trace["starts"]]
            answer = (destination / "answer.txt").read_text()
            artifact_path = work / case.get("artifact", "__no_artifact__")
            artifact = artifact_path.read_text() if artifact_path.is_file() and not artifact_path.is_symlink() else ""

            if artifact:
                (destination / case["artifact"]).write_text(artifact)

            result["checks"] = grade(case, answer, artifact, before, snapshot(work), trace, children, marker)
            result["status"] = "PASS" if all(check["passed"] for check in result["checks"]) else "FAIL"
            result["thread_id"] = thread_id
            result["parent_context"] = trace["contexts"]
            (destination / "trace.json").write_text(json.dumps({"parent": retained_trace(trace), "children": [retained_trace(child) for child in children]}, indent=2))
    except (OSError, RuntimeError, subprocess.CalledProcessError, ValueError, StopIteration) as cause:
        result["error"] = str(cause)

    result["duration_seconds"] = round(time.monotonic() - started, 2)
    (destination / "result.json").write_text(json.dumps(result, indent=2, ensure_ascii=False) + "\n")
    failures = [check["name"] for check in result["checks"] if not check["passed"]]
    print(f"{result['status']} {case['id']} ({result['duration_seconds']}s) {', '.join(failures) or result.get('error', '')}", flush=True)
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--case", action="append", help="Run only this case; repeatable")
    parser.add_argument("--jobs", type=int, default=2, choices=range(1, 4))
    parser.add_argument("--timeout", type=int, default=180)
    parser.add_argument("--output", type=Path)
    parser.add_argument("--list", action="store_true")
    options = parser.parse_args()

    if options.timeout <= 0:
        parser.error("--timeout must be positive")

    cases = json.loads(CASES.read_text())

    if options.case:
        unknown = set(options.case) - {case["id"] for case in cases}

        if unknown:
            parser.error(f"Unknown cases: {', '.join(sorted(unknown))}")

        cases = [case for case in cases if case["id"] in options.case]

    if options.list:
        print("\n".join(case["id"] for case in cases))
        return 0

    stamp = datetime.datetime.now(datetime.timezone.utc).strftime("%Y%m%dT%H%M%SZ")
    results = (options.output or ROOT / "eval-results" / stamp).resolve()
    results.mkdir(parents=True, exist_ok=False)
    shutil.copyfile(CASES, results / "cases.json")
    source_hashes = {}

    for directory in [ROOT / "skills", ROOT / ".agents/skills"]:
        for path in directory.rglob("*"):
            if path.is_file() and "evals" not in path.relative_to(directory).parts:
                source_hashes[str(path.relative_to(ROOT))] = hashlib.sha256(path.read_bytes()).hexdigest()

    manifest = {
        "codex_version": command(["codex", "--version"], ROOT),
        "source_hashes": source_hashes,
        "timeout_seconds": options.timeout,
        "concurrency": options.jobs,
        "scope": "Explicit skill invocation; one sample per case, no optimization baseline",
        "runner_sha256": hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
        "fixture_hashes": {
            str(path.relative_to(ROOT)): hashlib.sha256(path.read_bytes()).hexdigest()
            for directory in [ROOT / "evals", ROOT / "skills"]
            for path in directory.rglob("*")
            if path.is_file() and (directory.name == "evals" or "evals" in path.relative_to(directory).parts)
        },
    }
    (results / "manifest.json").write_text(json.dumps(manifest, indent=2) + "\n")
    print(f"Results: {results}", flush=True)

    with concurrent.futures.ThreadPoolExecutor(max_workers=options.jobs) as pool:
        outcomes = list(pool.map(lambda case: run_case(case, results, options.timeout), cases))

    summary = {"created_at": stamp, "cases": outcomes,
               "passed": sum(outcome["status"] == "PASS" for outcome in outcomes),
               "failed": sum(outcome["status"] == "FAIL" for outcome in outcomes),
               "errors": sum(outcome["status"] == "ERROR" for outcome in outcomes)}
    (results / "summary.json").write_text(json.dumps(summary, indent=2, ensure_ascii=False) + "\n")
    lines = ["# Skill behavioral evaluation", "", f"{summary['passed']} passed; {summary['failed']} failed; {summary['errors']} errors.",
             "", "| Case | Result | Failed checks |", "| --- | --- | --- |"]

    for outcome in outcomes:
        failed = [check["name"] for check in outcome["checks"] if not check["passed"]]
        lines.append(f"| {outcome['id']} | {outcome['status']} | {', '.join(failed) or outcome.get('error', '')} |")

    (results / "report.md").write_text("\n".join(lines) + "\n")
    print(f"Finished: {summary['passed']} passed, {summary['failed']} failed, {summary['errors']} errors", flush=True)
    return 0 if summary["failed"] == summary["errors"] == 0 else 1


if __name__ == "__main__":
    raise SystemExit(main())
