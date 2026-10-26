"""Regression tests for behavioral grading; these do not call a model."""

import copy
import json
import unittest

from run_skill_evals import CASES, grade, retained_trace


class BehavioralGraderTests(unittest.TestCase):
    def setUp(self):
        self.case = {"skill": "commit-message", "spawn": {"model": "gpt-6-luna", "effort": "low"}}
        self.before = {"files": {"source.ts": "original"}, "head": "head", "index": "index"}
        self.trace = {
            "calls": [{"name": "spawn_agent", "arguments": {
                "model": "gpt-6-luna", "reasoning_effort": "low", "fork_turns": "none",
            }}],
            "messages": ["Message Type: FINAL_ANSWER\nPayload:\nfeat: ✨ add retries"],
        }
        self.child = {
            "thread_id": "child", "contexts": [{"model": "gpt-6-luna", "effort": "low"}],
            "user_text": ["Inspect the staged diff."], "starts": [],
            "calls": [{"name": "exec", "arguments": 'git diff --cached --no-ext-diff'}],
        }

    def failures(self, after=None):
        checks = grade(self.case, "feat: ✨ add retries", "", self.before,
                       after or self.before, self.trace, [self.child], "PRIVATE_CANARY")
        return {check["name"] for check in checks if not check["passed"]}

    def test_should_accept_matching_actual_model_effort_and_fresh_context(self):
        self.assertEqual(self.failures(), set())

    def test_should_reject_wrong_actual_model_even_when_spawn_requested_correct_model(self):
        self.child["contexts"][0]["model"] = "gpt-6-astra"
        self.assertIn("effective_child_model", self.failures())

    def test_should_reject_wrong_requested_and_effective_effort(self):
        self.trace["calls"][0]["arguments"]["reasoning_effort"] = "high"
        self.child["contexts"][0]["effort"] = "high"
        self.assertTrue({"requested_effort", "effective_child_effort"} <= self.failures())

    def test_should_reject_history_fork_or_parent_marker_in_child(self):
        self.trace["calls"][0]["arguments"]["fork_turns"] = "all"
        self.child["user_text"].append("PRIVATE_CANARY")
        self.assertTrue({"fork_turns_none", "parent_marker_not_in_child_context"} <= self.failures())

    def test_should_reject_git_status_and_unstaged_diff(self):
        for invocation in ["git status --short", "git diff --stat", "git diff --stat && git diff --cached"]:
            with self.subTest(invocation=invocation):
                self.child["calls"][0]["arguments"] = invocation
                self.assertIn("staged_only_git_inspection", self.failures())

    def test_should_reject_changes_to_files_index_or_head(self):
        after = copy.deepcopy(self.before)
        after["files"]["source.ts"] = "changed"
        after["index"] = "changed"
        self.assertTrue({"only_permitted_file_changes", "git_head_and_index_unchanged"} <= self.failures(after))

    def test_should_reject_parent_rewriting_child_output(self):
        self.trace["messages"] = ["Message Type: FINAL_ANSWER\nPayload:\nfeat: ✨ something else"]
        self.assertIn("parent_preserves_child_report", self.failures())

    def test_should_reject_missing_child_context(self):
        self.child["contexts"] = []
        self.assertTrue({"effective_child_model", "effective_child_effort"} <= self.failures())

    def test_should_require_bundled_reviewer_and_extra_checks_in_child_calls(self):
        self.case = {"skill": "trusted-review", "spawn": {}, "builtin": True}
        self.assertTrue({"child_loads_bundled_review_agent", "child_loads_extra_checks"} <= self.failures())

    def test_should_accept_a_structured_question_without_question_mark_in_final_answer(self):
        self.case = {"skill": "brainstorm", "asks_question": True}
        self.trace["calls"] = [{"name": "request_user_input_async", "arguments": {"questions": []}}]
        self.assertNotIn("asks_design_question", self.failures())

        self.trace["calls"] = []
        self.assertIn("asks_design_question", self.failures())

    def test_should_accept_french_default_behavior_without_literal_default_word(self):
        case = next(case for case in json.loads(CASES.read_text()) if case["id"] == "pr-french")
        answer = "`fetchJson` relance une fois les requêtes en erreur. Le nombre de tentatives se règle avec `retries`."
        checks = grade(case, answer, "", self.before, self.before, self.trace, [], "PRIVATE_CANARY")
        self.assertTrue(all(check["passed"] for check in checks if check["name"].startswith("matches:")))

    def test_should_require_successful_hig_reads_not_just_attempted_commands(self):
        self.case = {"skill": "apple-hig", "cache": True}
        self.trace["calls"] = [
            {"name": "shell_execution", "arguments": {"command": f"python3 hig.py read {page}", "exit_code": 0}}
            for page in ["toolbars", "search-fields"]
        ]
        self.assertFalse(any(name.startswith("hig_page_read_success:") for name in self.failures()))

        self.trace["calls"][0]["arguments"]["exit_code"] = 1
        self.assertIn("hig_page_read_success:toolbars", self.failures())

    def test_should_omit_user_context_and_spawn_messages_from_selected_traces(self):
        self.trace["user_text"] = ["PRIVATE_CANARY"]
        self.trace["calls"][0]["arguments"]["message"] = "private briefing"
        retained = retained_trace(self.trace)
        self.assertNotIn("user_text", retained)
        self.assertNotIn("messages", retained)
        self.assertNotIn("message", retained["calls"][0]["arguments"])


if __name__ == "__main__":
    unittest.main()
