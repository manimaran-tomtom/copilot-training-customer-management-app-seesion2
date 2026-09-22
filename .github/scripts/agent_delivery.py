#!/usr/bin/env python3

import argparse
import json
import re
import subprocess
from pathlib import Path


REQUIRED_PLAN_SECTIONS = (
    "Requirements",
    "Relevant Code",
    "Proposed Changes",
    "Test Cases",
    "Exclusions",
    "Risks and Questions",
)
ALLOWED_CHANGE_PREFIXES = (
    "backend/src/CustomerManagement.Api/",
    "backend/tests/CustomerManagement.UnitTests/",
    "backend/tests/CustomerManagement.AcceptanceTests/",
)
FORBIDDEN_CHANGE_PREFIXES = ("backend/src/CustomerManagement.Api/Migrations/",)


def fail(message):
    raise SystemExit(message)


def read_issue(path):
    with Path(path).open(encoding="utf-8") as stream:
        return json.load(stream)


def issue_labels(issue):
    return {
        label["name"] if isinstance(label, dict) else label
        for label in issue.get("labels", [])
    }


def validate_issue(args):
    issue = read_issue(args.issue_json)
    if issue.get("number") != args.issue_number:
        fail(f"Issue number mismatch: expected {args.issue_number}.")
    if issue.get("state") != "OPEN":
        fail("The selected issue must be open.")
    if "agent-task" not in issue_labels(issue):
        fail("The selected issue must have the agent-task label.")

    body = issue.get("body") or ""
    required_sections = ("Context and Inputs", "Expected Outputs", "Success Criteria")
    for section in required_sections:
        if not re.search(rf"^###\s+(?:\d+\.\s+)?{re.escape(section)}\s*$", body, re.MULTILINE | re.IGNORECASE):
            fail(f"Issue is missing the '{section}' section.")


def plan_prompt(issue, base_sha):
    return f"""You are the planning phase of a plan-to-implementation pipeline.

Read the repository and the task contract below. Produce a concrete implementation
plan only. Do not edit files, run commands, provide a patch, or include source-code
blocks. If the issue is ambiguous or cannot be implemented safely, set Status to
BLOCKED and explain why under Risks and Questions.

The response must use exactly this structure:

# Implementation Plan
Issue: #{issue["number"]}
Base-Commit: {base_sha}
Status: READY

## Requirements
Map the issue's required behaviour into explicit implementation requirements.

## Relevant Code
Name the existing files and symbols that establish the patterns to follow.

## Proposed Changes
List ordered, file-specific changes without writing the implementation.

## Test Cases
Map each success criterion to a concrete automated test.

## Exclusions
State the files and behaviours that must not change.

## Risks and Questions
Record assumptions, risks, or blocking questions. Write "None" when there are none.

Repository: {issue.get("repository", "current repository")}
Base commit: {base_sha}

Task contract:

Title: {issue["title"]}

{issue["body"]}
"""


def implementation_prompt(issue, base_sha, plan):
    return f"""You are the implementation phase of a plan-to-implementation pipeline.

Implement the validated plan below for issue #{issue["number"]}. Work only in:
- backend/src/CustomerManagement.Api/**
- backend/tests/CustomerManagement.UnitTests/**
- backend/tests/CustomerManagement.AcceptanceTests/**

Do not change workflows, course material, migrations, or the plan. Do not commit,
push, create a pull request, or use GitHub APIs. Follow the repository instructions
and the backend-engineer agent's conventions. You may inspect files, edit the
allowed paths, and run dotnet commands. Keep the change surgical. The workflow will
independently validate paths, build, and test.

Repository base commit: {base_sha}

Task contract:

Title: {issue["title"]}

{issue["body"]}

Validated plan:

{plan}
"""


def build_prompt(args):
    issue = read_issue(args.issue_json)
    if args.phase == "plan":
        prompt = plan_prompt(issue, args.base_sha)
    else:
        plan = Path(args.plan).read_text(encoding="utf-8")
        prompt = implementation_prompt(issue, args.base_sha, plan)
    Path(args.output).write_text(prompt, encoding="utf-8")


def validate_plan(args):
    plan = Path(args.plan).read_text(encoding="utf-8")
    required_metadata = (
        r"^# Implementation Plan\s*$",
        rf"^Issue:\s+#{args.issue_number}\s*$",
        rf"^Base-Commit:\s+{re.escape(args.base_sha)}\s*$",
        r"^Status:\s+READY\s*$",
    )
    for pattern in required_metadata:
        if not re.search(pattern, plan, re.MULTILINE):
            fail(f"Plan is missing required metadata matching: {pattern}")

    if re.search(r"^Status:\s+BLOCKED\s*$", plan, re.MULTILINE):
        fail("A blocked plan cannot proceed to implementation.")

    for section in REQUIRED_PLAN_SECTIONS:
        match = re.search(
            rf"^##\s+{re.escape(section)}\s*$([\s\S]*?)(?=^##\s+|\Z)",
            plan,
            re.MULTILINE,
        )
        if not match or len(match.group(1).strip()) < 3:
            fail(f"Plan section '{section}' is missing or empty.")

    forbidden = (r"^```", r"^diff --git ", r"^\+\+\+ [ab]/", r"^--- [ab]/")
    if any(re.search(pattern, plan, re.MULTILINE) for pattern in forbidden):
        fail("Plan must not contain code fences or a source-code patch.")


def changed_files(base_sha):
    commands = (
        ["git", "diff", "--name-only", "--diff-filter=ACMRTUXB", base_sha, "--"],
        ["git", "diff", "--name-only", "--diff-filter=D", base_sha, "--"],
        ["git", "ls-files", "--others", "--exclude-standard"],
    )
    paths = set()
    for command in commands:
        result = subprocess.run(command, check=True, capture_output=True, text=True)
        paths.update(line for line in result.stdout.splitlines() if line)
    return sorted(paths)


def validate_changes(args):
    paths = changed_files(args.base_sha)
    if not paths:
        fail("Implementation produced no changes.")

    invalid = [
        path
        for path in paths
        if not any(path.startswith(prefix) for prefix in ALLOWED_CHANGE_PREFIXES)
        or any(path.startswith(prefix) for prefix in FORBIDDEN_CHANGE_PREFIXES)
    ]
    if invalid:
        fail("Implementation changed out-of-scope paths:\n" + "\n".join(invalid))

    print("\n".join(paths))


def markdown_demote(text):
    return re.sub(
        r"^(#{1,6})(\s+)",
        lambda match: "##" + match.group(1) + match.group(2),
        text,
        flags=re.MULTILINE,
    )


def render_pr(args):
    issue = read_issue(args.issue_json)
    plan = Path(args.plan).read_text(encoding="utf-8").strip()
    evidence = Path(args.evidence).read_text(encoding="utf-8").strip()
    title = re.sub(r"^\[Agent Task\]:\s*", "", issue["title"]).strip()

    body = f"""## Plan

Implementation was produced in a fresh agent job from the validated planning
artifact below.

<details>
<summary>Validated implementation plan</summary>

{markdown_demote(plan)}

</details>

## Evidence

{evidence}

Closes #{issue["number"]}
"""
    Path(args.output).write_text(body, encoding="utf-8")
    Path(args.title_output).write_text(title, encoding="utf-8")


def parser():
    root = argparse.ArgumentParser()
    subcommands = root.add_subparsers(dest="command", required=True)

    issue = subcommands.add_parser("validate-issue")
    issue.add_argument("--issue-json", required=True)
    issue.add_argument("--issue-number", required=True, type=int)
    issue.set_defaults(handler=validate_issue)

    prompt = subcommands.add_parser("build-prompt")
    prompt.add_argument("--phase", choices=("plan", "implement"), required=True)
    prompt.add_argument("--issue-json", required=True)
    prompt.add_argument("--base-sha", required=True)
    prompt.add_argument("--plan")
    prompt.add_argument("--output", required=True)
    prompt.set_defaults(handler=build_prompt)

    plan = subcommands.add_parser("validate-plan")
    plan.add_argument("--plan", required=True)
    plan.add_argument("--issue-number", required=True, type=int)
    plan.add_argument("--base-sha", required=True)
    plan.set_defaults(handler=validate_plan)

    changes = subcommands.add_parser("validate-changes")
    changes.add_argument("--base-sha", required=True)
    changes.set_defaults(handler=validate_changes)

    pr = subcommands.add_parser("render-pr")
    pr.add_argument("--issue-json", required=True)
    pr.add_argument("--plan", required=True)
    pr.add_argument("--evidence", required=True)
    pr.add_argument("--output", required=True)
    pr.add_argument("--title-output", required=True)
    pr.set_defaults(handler=render_pr)

    return root


def main():
    args = parser().parse_args()
    if args.command == "build-prompt" and args.phase == "implement" and not args.plan:
        fail("--plan is required for the implement phase.")
    args.handler(args)


if __name__ == "__main__":
    main()
