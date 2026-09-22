Complete the following work in the specified order. Each step must build on the contract established by the previous step.

1. Create the pull request template

Create `.github/PULL_REQUEST_TEMPLATE/pull_request_template.md`.

The template must contain:

- A `## Plan` section where the pull request author explains what the change sets out to accomplish.
- An `## Evidence` section where the author provides the tests, checks, screenshots, logs, or other signals confirming the work is complete.

Include helpful guidance or placeholders that prompt authors to provide meaningful information without being mistaken for completed content.

2. Create the Plan Gate workflow

After creating the template, create `.github/workflows/plan-gate.yml`.

The workflow must:

- Run for every pull request.
- Inspect the pull request body.
- Verify that both the `Plan` and `Evidence` sections are present.
- Verify that each section contains meaningful content.
- Fail when either section is missing, empty, whitespace-only, or contains only unchanged template guidance or placeholder text.
- Contain exactly one job.
- Use `plan-gate` as the job ID.
- Give the job no `name:` field, ensuring the reported status-check name is `plan-gate`.

Implement the validation robustly so content is evaluated within the correct section boundaries rather than merely checking whether the words “Plan” and “Evidence” appear somewhere in the pull request.

3. Create the Copilot instructions

After the template and workflow are complete, create `.github/copilot-instructions.md`.

The instructions must require agents to:

- Use the repository’s pull request template.
- Complete both the `Plan` and `Evidence` sections in every pull request.
- Replace all guidance and placeholder text with meaningful, change-specific content.
- Describe the intended work in `Plan`.
- Provide concrete completion signals in `Evidence`.
- Author the pull request to satisfy the `plan-gate` required status check from the outset.

Ensure the template, workflow validation, and Copilot instructions use consistent section names and define one coherent pull request contract.