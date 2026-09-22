# assets/

Place static resources here that the skill references — templates, schemas,
lookup tables, diagrams, or any file the agent reads but does not execute.

## Examples

- `request-template.json` — a JSON body the agent fills in and posts
- `schema.yaml` — an OpenAPI or JSON Schema the agent validates against
- `diagram.png` — an architecture diagram included for context

## Reference from SKILL.md

Use relative paths from the skill root:

```markdown
Use the request template at `assets/request-template.json` as the base body.
```

## Delete this folder

If your skill does not need any static assets, delete this directory.
