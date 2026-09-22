import importlib.util
import json
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch


SCRIPT = Path(__file__).parents[1] / "agent_delivery.py"
SPEC = importlib.util.spec_from_file_location("agent_delivery", SCRIPT)
agent_delivery = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(agent_delivery)


class AgentDeliveryTests(unittest.TestCase):
    def setUp(self):
        self.__temporary_directory = tempfile.TemporaryDirectory()
        self.__root = Path(self.__temporary_directory.name)
        self.__issue = {
            "number": 17,
            "title": "[Agent Task]: Get product - API and unit tests",
            "state": "OPEN",
            "labels": [{"name": "agent-task"}],
            "body": (
                "### 1. Context and Inputs\nContext\n\n"
                "### 2. Expected Outputs\nOutputs\n\n"
                "### 3. Success Criteria\nCriteria\n"
            ),
        }
        self.__issue_path = self.__root / "issue.json"
        self.__issue_path.write_text(json.dumps(self.__issue), encoding="utf-8")

    def tearDown(self):
        self.__temporary_directory.cleanup()

    def test_validate_issue_accepts_agent_task_contract(self):
        args = type("Args", (), {"issue_json": self.__issue_path, "issue_number": 17})
        agent_delivery.validate_issue(args)

    def test_validate_issue_rejects_wrong_issue_number(self):
        args = type("Args", (), {"issue_json": self.__issue_path, "issue_number": 18})
        with self.assertRaisesRegex(SystemExit, "Issue number mismatch"):
            agent_delivery.validate_issue(args)

    def test_validate_plan_requires_ready_structured_handoff(self):
        plan_path = self.__root / "plan.md"
        sections = "\n".join(
            f"## {section}\nContent for {section}.\n"
            for section in agent_delivery.REQUIRED_PLAN_SECTIONS
        )
        plan_path.write_text(
            "# Implementation Plan\n"
            "Issue: #17\n"
            "Base-Commit: abc123\n"
            "Status: READY\n\n"
            f"{sections}",
            encoding="utf-8",
        )
        args = type(
            "Args",
            (),
            {"plan": plan_path, "issue_number": 17, "base_sha": "abc123"},
        )
        agent_delivery.validate_plan(args)

    def test_validate_plan_rejects_code_fence(self):
        plan_path = self.__root / "plan.md"
        sections = "\n".join(
            f"## {section}\nContent for {section}.\n"
            for section in agent_delivery.REQUIRED_PLAN_SECTIONS
        )
        plan_path.write_text(
            "# Implementation Plan\n"
            "Issue: #17\n"
            "Base-Commit: abc123\n"
            "Status: READY\n\n"
            f"{sections}\n```csharp\ncode\n```\n",
            encoding="utf-8",
        )
        args = type(
            "Args",
            (),
            {"plan": plan_path, "issue_number": 17, "base_sha": "abc123"},
        )
        with self.assertRaisesRegex(SystemExit, "must not contain"):
            agent_delivery.validate_plan(args)

    def test_validate_plan_rejects_blocked_status_even_if_ready_is_mentioned(self):
        plan_path = self.__root / "plan.md"
        sections = "\n".join(
            f"## {section}\nContent for {section}.\n"
            for section in agent_delivery.REQUIRED_PLAN_SECTIONS
        )
        plan_path.write_text(
            "# Implementation Plan\n"
            "Issue: #17\n"
            "Base-Commit: abc123\n"
            "Status: BLOCKED\n\n"
            f"{sections}\nA future plan may use Status: READY.\n",
            encoding="utf-8",
        )
        args = type(
            "Args",
            (),
            {"plan": plan_path, "issue_number": 17, "base_sha": "abc123"},
        )
        with self.assertRaisesRegex(SystemExit, "required metadata"):
            agent_delivery.validate_plan(args)

    @patch.object(agent_delivery, "changed_files")
    def test_validate_changes_rejects_workflow_edits(self, changed_files):
        changed_files.return_value = [".github/workflows/ci.yml"]
        args = type("Args", (), {"base_sha": "abc123"})
        with self.assertRaisesRegex(SystemExit, "out-of-scope"):
            agent_delivery.validate_changes(args)

    @patch.object(agent_delivery, "changed_files")
    def test_validate_changes_accepts_backend_and_unit_test_edits(self, changed_files):
        changed_files.return_value = [
            "backend/src/CustomerManagement.Api/Program.cs",
            "backend/tests/CustomerManagement.UnitTests/GetProductTests.cs",
        ]
        args = type("Args", (), {"base_sha": "abc123"})
        agent_delivery.validate_changes(args)

    @patch.object(agent_delivery, "changed_files")
    def test_validate_changes_accepts_acceptance_test_edits(self, changed_files):
        changed_files.return_value = [
            "backend/tests/CustomerManagement.AcceptanceTests/Features/GetProduct.feature",
            "backend/tests/CustomerManagement.AcceptanceTests/Features/GetProduct.feature.cs",
            "backend/tests/CustomerManagement.AcceptanceTests/StepDefinitions/GetProductSteps.cs",
        ]
        args = type("Args", (), {"base_sha": "abc123"})
        agent_delivery.validate_changes(args)

    def test_build_prompt_implementation_allows_acceptance_tests(self):
        plan_path = self.__root / "plan.md"
        output_path = self.__root / "implementation-prompt.md"
        plan_path.write_text("# Implementation Plan", encoding="utf-8")
        args = type(
            "Args",
            (),
            {
                "phase": "implement",
                "issue_json": self.__issue_path,
                "base_sha": "abc123",
                "plan": plan_path,
                "output": output_path,
            },
        )

        agent_delivery.build_prompt(args)

        prompt = output_path.read_text(encoding="utf-8")
        self.assertIn("backend/tests/CustomerManagement.AcceptanceTests/**", prompt)
        self.assertNotIn("Do not change workflows, course material, acceptance tests", prompt)

    @patch.object(agent_delivery, "changed_files")
    def test_validate_changes_rejects_migrations(self, changed_files):
        changed_files.return_value = [
            "backend/src/CustomerManagement.Api/Migrations/Unexpected.cs"
        ]
        args = type("Args", (), {"base_sha": "abc123"})
        with self.assertRaisesRegex(SystemExit, "out-of-scope"):
            agent_delivery.validate_changes(args)

    def test_render_pr_preserves_plan_and_evidence_contract(self):
        plan_path = self.__root / "plan.md"
        evidence_path = self.__root / "evidence.md"
        output_path = self.__root / "pr.md"
        title_path = self.__root / "title.txt"
        plan_path.write_text("# Implementation Plan\n## Tests\nRun tests.", encoding="utf-8")
        evidence_path.write_text("- Unit tests passed.", encoding="utf-8")
        args = type(
            "Args",
            (),
            {
                "issue_json": self.__issue_path,
                "plan": plan_path,
                "evidence": evidence_path,
                "output": output_path,
                "title_output": title_path,
            },
        )

        agent_delivery.render_pr(args)

        body = output_path.read_text(encoding="utf-8")
        self.assertIn("## Plan", body)
        self.assertIn("## Evidence", body)
        self.assertIn("### Implementation Plan", body)
        self.assertIn("Closes #17", body)
        self.assertEqual(
            "Get product - API and unit tests",
            title_path.read_text(encoding="utf-8"),
        )


if __name__ == "__main__":
    unittest.main()
