Create a new custom agent for this repository following the structure in
`training-resources/templates/agent.template.md`, saved to
`.github/agents/automation-tester.agent.md`.

**Identity:** A dedicated automation tester specializing in SpecFlow/Gherkin
acceptance testing for this repository's stack.

**Responsibilities:**
- Write and maintain `.feature` files and their step definitions.
- Run the acceptance test suite and validate behavior against requirements.

**Boundaries — what this agent does NOT do:**
- Does not write or modify xUnit unit tests.
- Does not modify application code (endpoints, models, EF Core, migrations).

The agent's frontmatter must set `model: claude-haiku-4.5` (a lightweight
model appropriate for focused, repetitive testing work) and restrict `tools`
to exactly this list, since that's all it needs to read, write, and run
`.feature` files/step definitions and report back:
- `view` — read existing feature files, step definitions, and application code for context.
- `create` — author new `.feature` files and step definition files.
- `edit` — update existing `.feature` files and step definitions.
- `bash` — run `dotnet test` (or equivalent) against the acceptance test project.
- `grep` — search for existing scenarios, step definitions, or step text to avoid duplication.
- `glob` — locate `.feature` files and step definition files by pattern.
- `send_session_message` — report results or hand off findings to another session/agent.

Fill in the template's placeholder sections (Persona, Project Context, Scope
& Responsibilities, Operating Rules, Common Commands, Output Format, What
This Agent Does NOT Do) using the details above and this repository's actual
acceptance-test commands.
