"""Verify rule migration without touching the installed Codex configuration."""

import os
from pathlib import Path
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]
REFERENCES = ROOT / "skills/coding-preferences/references"


class InstructionSyncTests(unittest.TestCase):
    def sync(self, target):
        return subprocess.run(
            ["bash", str(ROOT / "sync-agents-md.sh")],
            env={**os.environ, "CODEX_HOME": str(target)},
            capture_output=True, text=True, check=True, timeout=10,
        ).stdout

    def test_should_remove_only_unchanged_managed_rules(self):
        with tempfile.TemporaryDirectory(prefix="codex-rule-migration-") as temporary:
            target = Path(temporary)
            rules = target / "rules"
            rules.mkdir()

            for source in REFERENCES.glob("*.md"):
                (rules / source.name).write_bytes(source.read_bytes())

            (rules / "react.md").write_text("Local user edits\n")
            (rules / "unrelated.md").write_text("Unrelated preference\n")

            output = self.sync(target)

            self.assertIn("Preserved modified legacy rule", output)
            self.assertEqual(sorted(path.name for path in rules.iterdir()), ["react.md", "unrelated.md"])
            self.assertEqual((rules / "react.md").read_text(), "Local user edits\n")
            self.assertEqual((rules / "unrelated.md").read_text(), "Unrelated preference\n")
            self.assertEqual((target / "AGENTS.md").read_bytes(), (ROOT / "AGENTS.md").read_bytes())

            second_output = self.sync(target)

            self.assertIn("Already up to date", second_output)
            self.assertNotIn("Removed migrated rule", second_output)
            self.assertEqual(sorted(path.name for path in rules.iterdir()), ["react.md", "unrelated.md"])

    def test_should_install_without_creating_a_legacy_rule_directory(self):
        with tempfile.TemporaryDirectory(prefix="codex-fresh-instructions-") as temporary:
            target = Path(temporary)

            self.sync(target)

            self.assertFalse((target / "rules").exists())
            self.assertEqual((target / "AGENTS.md").read_bytes(), (ROOT / "AGENTS.md").read_bytes())
            self.assertEqual(
                (target / "output-styles/scannable.md").read_bytes(),
                (ROOT / "output-styles/scannable.md").read_bytes(),
            )


if __name__ == "__main__":
    unittest.main()
