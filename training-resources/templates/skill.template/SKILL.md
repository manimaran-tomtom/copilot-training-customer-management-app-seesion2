---
name: skill-name
description: >
  One or two sentences describing what this skill does and when to use it.
  Include the task it enables, the keywords an agent should match on, and any
  contexts where it applies even if the user does not name the domain explicitly.
  Keep it under 1024 characters — this is loaded at startup for every skill so
  clarity and precision matter more than length.

# Optional fields — remove any that do not apply

# license: MIT
# compatibility: Requires git and .NET 8+
# metadata:
#   author: your-name
#   version: "1.0"
# allowed-tools: Bash(git:*) Read
---

## When to Use This Skill

Describe the exact situations where an agent should activate this skill.
Be concrete — list the user actions, keywords, or task patterns that are a
reliable signal. Also note situations that *look* relevant but are not, so the
agent does not trigger unnecessarily.

- **Do use** when: <specific trigger condition 1>
- **Do use** when: <specific trigger condition 2>
- **Do NOT use** when: <near-miss situation that belongs elsewhere>

## Workflow

A numbered, ordered sequence of the steps needed to complete the task.
Each step should be a discrete, testable action. Where the sequence matters,
say so. Where the agent has freedom, give it.

1. **<Step name>** — <what to do and why>.

   ```bash
   # Example command if applicable
   ```

2. **<Step name>** — <what to do and why>.

3. **<Step name>** — <what to do and why>.

4. **Verify** — Confirm the expected outcome before finishing. State clearly
   what "done" looks like so the agent can self-check.

## Examples

Show one representative input → output pair. Concrete examples help the agent
pattern-match to the right behaviour faster than prose alone.

**Input:**

```
<sample input, prompt, or file content>
```

**Expected output / result:**

```
<sample output, response, or file content>
```

## Gotchas

A short list of non-obvious pitfalls specific to this skill — things the agent
would get wrong without being told. Do not list things the agent already knows.

- **<Pitfall name>:** <what goes wrong and how to avoid it>.
- **<Pitfall name>:** <what goes wrong and how to avoid it>.

## Rules

Numbered, non-negotiable constraints the agent must respect when this skill is
active. Keep the list short — only add a rule if breaking it would cause a real
problem.

1. **<Rule name>** — <what to do / not do and why>.
2. **<Rule name>** — <what to do / not do and why>.

---

<!-- NAMING RULES
  The `name` field above MUST match the parent directory name exactly.
  e.g.  name: my-skill  →  directory: my-skill/SKILL.md
  Rules: lowercase a-z, 0-9, hyphens only; no leading/trailing/consecutive
  hyphens; max 64 characters.

  WHERE TO PLACE SKILLS (GitHub Copilot)
  Project (this repository): .github/skills/<skill-name>/SKILL.md
  Personal (all repos):      ~/.copilot/skills/<skill-name>/SKILL.md
-->
