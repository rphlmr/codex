"""Regression tests for behavioral grading; these do not call a model."""

import copy
import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

from run_skill_evals import CASES, codex_arguments, grade, main, retained_trace, session_trace


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

    def failures(self, after=None, answer="feat: ✨ add retries"):
        checks = grade(self.case, answer, "", self.before,
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

    def test_should_allow_trusted_review_summary_when_reviewer_report_is_available(self):
        self.case = {"skill": "trusted-review", "spawn": {}}
        self.trace["messages"] = ["Message Type: FINAL_ANSWER\nPayload:\n[P2] Include the free-shipping threshold."]
        self.assertEqual(self.failures(answer="The threshold defect is confirmed. Review complete."), set())

    def test_should_reject_trusted_review_without_a_completed_reviewer_report(self):
        self.case = {"skill": "trusted-review", "spawn": {}}

        for messages in ([], ["Message Type: FINAL_ANSWER\nPayload:\n"], ["Message Type: MESSAGE\nPayload:\nWorking."]):
            with self.subTest(messages=messages):
                self.trace["messages"] = messages
                self.assertIn("reviewer_report_available", self.failures(answer="No findings."))

    def test_should_keep_pr_changelog_output_exact(self):
        self.case = {"skill": "pr-changelog", "spawn": {}}
        self.trace["messages"] = ["Message Type: FINAL_ANSWER\nPayload:\nA complete PR description."]
        self.assertEqual(self.failures(answer="A complete PR description."), set())
        self.assertIn("parent_preserves_child_report", self.failures(answer="A shortened PR description."))

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

    def test_should_recognize_repeated_events_without_a_repeat_keyword(self):
        case = next(case for case in json.loads(CASES.read_text()) if case["id"] == "state-explicit-switch")

        for sequence in ("accept → accept", "submit -> submit", "submit again", "duplicate acceptance"):
            with self.subTest(sequence=sequence):
                answer = f"Explicit machine. Effects are gated by pending state. Validate {sequence}."
                checks = grade(case, answer, "", self.before, self.before,
                               {"calls": []}, [], "PRIVATE_CANARY")
                self.assertEqual([check["name"] for check in checks if not check["passed"]], [])

        answer = "Explicit machine. Effects are gated by pending state. Validate submit → accept."
        checks = grade(case, answer, "", self.before, self.before, {"calls": []}, [], "PRIVATE_CANARY")
        self.assertEqual([check["name"] for check in checks if not check["passed"]],
                         ["matches:" + case["patterns"][-1]])

    def test_should_require_successful_hig_reads_not_just_attempted_commands(self):
        self.case = {"skill": "apple-hig", "cache": True}
        self.trace["calls"] = [
            {"name": "shell_execution", "arguments": {"command": f"python3 hig.py read {page}", "exit_code": 0}}
            for page in ["toolbars", "search-fields"]
        ]
        self.assertFalse(any(name.startswith("hig_page_read_success:") for name in self.failures()))

        self.trace["calls"][0]["arguments"]["exit_code"] = 1
        self.assertIn("hig_page_read_success:toolbars", self.failures())

    def test_should_forward_the_requested_model_and_effort_with_read_only_sandboxing(self):
        arguments = codex_arguments({}, Path("fixture"), Path("answer.txt"), {
            "model": "gpt-6-astra", "effort": "xhigh",
        })
        self.assertEqual(arguments[arguments.index("--model") + 1], "gpt-6-astra")
        self.assertIn('model_reasoning_effort="xhigh"', arguments)
        self.assertEqual(arguments[arguments.index("-s") + 1], "read-only")
        self.assertEqual(arguments[-1], "-")

    def test_should_reject_a_profile_mismatch_in_the_parent_or_inherited_reviewer(self):
        profile = {"model": "gpt-6-astra", "effort": "high"}
        self.trace["contexts"] = [profile]
        self.case = {"skill": "trusted-review", "spawn": {}}
        self.child["contexts"] = [profile]
        checks = grade(self.case, "Summary", "", self.before, self.before,
                       self.trace, [self.child], "PRIVATE_CANARY", profile)
        self.assertTrue(all(check["passed"] for check in checks))

        self.trace["contexts"] = [{"model": "gpt-6.1-sol", "effort": None}]
        self.child["contexts"] = [{"model": "gpt-6-astra", "effort": "medium"}]
        checks = grade(self.case, "Summary", "", self.before, self.before,
                       self.trace, [self.child], "PRIVATE_CANARY", profile)
        failures = {check["name"] for check in checks if not check["passed"]}
        self.assertTrue({"effective_parent_model", "effective_parent_effort", "effective_child_effort"} <= failures)

    def test_should_read_effort_from_the_recorded_collaboration_settings(self):
        with tempfile.TemporaryDirectory() as temporary:
            codex_dir = Path(temporary)
            session = codex_dir / "sessions/2026/11/03/rollout-profile.jsonl"
            session.parent.mkdir(parents=True)
            session.write_text(json.dumps({"type": "turn_context", "payload": {
                "model": "gpt-6-astra",
                "collaboration_mode": {"settings": {"reasoning_effort": "max"}},
            }}) + "\n")

            with patch.dict("os.environ", {"CODEX_HOME": str(codex_dir)}):
                self.assertEqual(session_trace("profile")["contexts"], [{"model": "gpt-6-astra", "effort": "max"}])

    def test_should_accept_equivalent_closed_handoff_phrasings(self):
        case = next(case for case in json.loads(CASES.read_text()) if case["id"] == "handoff-closed-review")

        for closure in (
            "There are no known blockers, and no work remains.",
            "No tasks remain.",
            "No remaining work.",
            "No pending tasks.",
            "Nothing remains.",
            "Remaining work: none.",
            "Remaining tasks: 0.",
        ):
            with self.subTest(closure=closure):
                answer = f"Implementation and review are complete. {closure} Deployment is not authorized."
                checks = grade(case, answer, "", self.before, self.before, {"calls": []}, [], "PRIVATE_CANARY")
                self.assertEqual([check["name"] for check in checks if not check["passed"]], [])

    def test_should_reject_handoff_with_remaining_or_unspecified_work(self):
        case = next(case for case in json.loads(CASES.read_text()) if case["id"] == "handoff-closed-review")

        for closure in ("Some work remains.", "Tasks remain.", "Remaining tasks: 10.", "Remaining tasks: 01.", ""):
            with self.subTest(closure=closure):
                answer = f"Implementation and review are complete. {closure} Deployment is not authorized."
                checks = grade(case, answer, "", self.before, self.before, {"calls": []}, [], "PRIVATE_CANARY")
                self.assertEqual(
                    [check["name"] for check in checks if not check["passed"]],
                    [f"matches:{case['patterns'][1]}"],
                )

    def test_should_allow_zero_or_one_scoped_reviewer_for_architecture_triage(self):
        case = next(case for case in json.loads(CASES.read_text()) if case["id"] == "state-preference-not-blocker")
        answer = "An architectural preference alone does not require conversion."
        self.child["calls"] = [{"name": "exec", "arguments": (
            "cat skills/.system/review-agent/SKILL.md trusted-review/references/review.md src/outbox.ts"
        )}]

        for trace, children in (({"calls": []}, []), (self.trace, [self.child])):
            with self.subTest(reviewers=len(children)):
                checks = grade(case, answer, "", self.before, self.before, trace, children, "PRIVATE_CANARY")
                self.assertEqual([check["name"] for check in checks if not check["passed"]], [])

    def test_should_reject_multiple_or_untraced_optional_reviewers(self):
        case = {"skill": "state-machines", "optional_review": True}
        spawn = self.trace["calls"][0]

        for calls, children in (
            ([spawn, spawn], [self.child, self.child]),
            ([spawn], []),
            ([], [self.child]),
        ):
            with self.subTest(spawns=len(calls), children=len(children)):
                trace = {**self.trace, "calls": calls}
                checks = grade(case, "Summary", "", self.before, self.before, trace, children, "PRIVATE_CANARY")
                failures = {check["name"] for check in checks if not check["passed"]}
                self.assertIn("at_most_one_fresh_reviewer", failures)

    def test_should_require_optional_reviewer_isolation_and_scope_evidence(self):
        self.case = {
            "skill": "state-machines", "optional_review": True,
            "builtin": True, "review_scope": ["src/outbox.ts"],
        }
        self.trace["calls"][0]["arguments"]["fork_turns"] = "all"
        self.child["calls"] = [{"name": "spawn_agent", "arguments": {}}]
        self.child["user_text"].append("PRIVATE_CANARY")
        self.trace["messages"] = []
        self.assertTrue({
            "fork_turns_none", "parent_marker_not_in_child_context", "no_recursive_delegation",
            "child_loads_bundled_review_agent", "child_loads_extra_checks",
            "reviewer_scope_reference:src/outbox.ts", "reviewer_report_available",
        } <= self.failures())

    def test_should_still_reject_delegation_for_repeated_reassurance(self):
        self.case = next(case for case in json.loads(CASES.read_text()) if case["id"] == "review-repeated-reassurance")
        self.assertIn("no_delegation", self.failures(answer="Review complete. Recommend closure."))

    def test_should_regrade_offline_without_erasing_originals_other_failures_or_errors(self):
        with tempfile.TemporaryDirectory() as temporary:
            source = Path(temporary) / "original"
            destination = Path(temporary) / "regraded"
            source.mkdir()
            cases = [{"id": name, "skill": "trusted-review", "spawn": {}}
                     for name in ("summary", "real-failure", "runtime-error")]
            outcomes = []

            for case in cases:
                case_dir = source / case["id"]
                case_dir.mkdir()
                (case_dir / "answer.txt").write_text("A concise summary.")
                outcomes.append({"id": case["id"], "skill": case["skill"], "thread_id": case["id"],
                                 "status": "FAIL", "checks": [
                                     {"name": "one_fresh_agent", "passed": case["id"] != "real-failure"},
                                     {"name": "parent_preserves_child_report", "passed": False},
                                 ]})

            outcomes[-1] = {**outcomes[-1], "status": "ERROR", "error": "Timed out"}
            (source / "cases.json").write_text(json.dumps(cases))
            (source / "summary.json").write_text(json.dumps({"created_at": "original-time", "cases": outcomes}))
            (source / "manifest.json").write_text(json.dumps({"runner_sha256": "original-runner"}))
            originals = {path: path.read_bytes() for path in source.rglob("*") if path.is_file()}
            trace = {"messages": ["Message Type: FINAL_ANSWER\nPayload:\nThe complete reviewer report."]}

            with patch("sys.argv", ["runner", "--regrade", str(source), "--output", str(destination)]), \
                    patch("run_skill_evals.session_trace", return_value=trace) as read_trace, \
                    patch("run_skill_evals.run_case", side_effect=AssertionError("Must not run models")) as run_model, \
                    patch("run_skill_evals.subprocess.Popen", side_effect=AssertionError("Must not launch processes")):
                self.assertEqual(main(), 1)
                run_model.assert_not_called()
                self.assertEqual(read_trace.call_count, 2)

            summary = json.loads((destination / "summary.json").read_text())
            self.assertEqual((summary["passed"], summary["failed"], summary["errors"]), (1, 1, 1))
            self.assertEqual(summary["created_at"], "original-time")
            self.assertEqual(summary["regraded_from"], str(source.resolve()))
            self.assertEqual(summary["cases"][2], outcomes[2])
            self.assertEqual(originals, {path: path.read_bytes() for path in source.rglob("*") if path.is_file()})

            with patch("sys.argv", ["runner", "--regrade", str(source), "--output", str(destination)]), \
                    patch("run_skill_evals.session_trace", return_value=trace):
                with self.assertRaises(FileExistsError):
                    main()

    def test_should_omit_user_context_and_spawn_messages_from_selected_traces(self):
        self.trace["user_text"] = ["PRIVATE_CANARY"]
        self.trace["calls"][0]["arguments"]["message"] = "private briefing"
        retained = retained_trace(self.trace)
        self.assertNotIn("user_text", retained)
        self.assertNotIn("messages", retained)
        self.assertNotIn("message", retained["calls"][0]["arguments"])


if __name__ == "__main__":
    unittest.main()
