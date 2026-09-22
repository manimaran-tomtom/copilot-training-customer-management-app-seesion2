Create two path-specific Copilot instruction files (`.github/instructions/*.instructions.md`, each with `applyTo` targeting C# files) capturing the conventions you identified from reviewing the existing endpoints and unit tests:

1. **API/endpoint conventions** — scoped to the Minimal API source (e.g. `backend/src/CustomerManagement.Api/**/*.cs`). Cover the Swagger documentation requirements (`.WithName`, `.WithTags`, `.WithSummary`, `.WithDescription`, `.Produces<T>`, `.ProducesValidationProblem`), XML doc comments with `<example>` tags on request/response models, and validation/status-code conventions.

2. **Unit-testing conventions** — scoped to the unit test project (e.g. `backend/tests/CustomerManagement.UnitTests/**/*.cs`). Cover the `WebApplicationFactory<Program>` + in-memory SQLite setup pattern, Arrange/Act/Assert structure, and the `MethodUnderTest_Scenario_ExpectedResult` naming convention.

Each file should have a clear `description` and `applyTo` glob in its frontmatter, followed by concise, actionable rules (not prose) that Copilot should follow when editing matching files.
