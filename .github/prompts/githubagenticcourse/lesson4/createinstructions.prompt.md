Create the following two Markdown files:

1. A conditional instruction file at `.github/instructions/backend.instructions.md`.

Configure its `applyTo` glob pattern so that it applies only to files under the `backend/` directory, including all nested files.

The instruction must state:

- Every private field must begin with exactly two underscores (`__`).
- Every non-private field must begin with exactly one underscore (`_`), not two.
- All unit test method names must be upper case - e.g., `TEST_MY_FUNCTION`.

2. A skill called `code-review`, following the repository's existing skill conventions. Ensure the description clearly states this skill is used during the code review process in GitHub Copilot agentic code reviews. 

The skill's procedure must require the following order:

1. Before reviewing the application, find and read all applicable instruction files, including conditional instruction files whose glob patterns match the files under review. Apply those instructions throughout the review.
2. Check any tests in the PR accurately satisfy the acceptance criteria.

IMPORTANT: All comments left on a PR as a consequence of the `code-review` skill must begin with `CODE-REVIEW:`.

Once you have created it, push the changes to the repository.