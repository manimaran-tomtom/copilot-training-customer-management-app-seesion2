Create a skill at `.github/skills/api-validation/SKILL.md` for validating a newly built or changed API endpoint end-to-end.

The `description` field must be written as a trigger-condition sentence (e.g. "Use when an API endpoint has been added or changed and needs to be validated before considering the work done.").

Encode this six-step procedure as the skill's instructions:

1. Build the application and confirm it starts without errors.
2. Confirm the endpoint is visible in Swagger.
3. Identify all possible responses the endpoint can return (200, 404, 400, etc.).
4. Test each response by calling the endpoint with appropriate inputs.
5. If the endpoint writes to the database, confirm the data has been persisted correctly.
6. If anything does not behave as expected, stop and present the error to the user rather than continuing or working around it.
