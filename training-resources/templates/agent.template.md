---
description: >
  One or two sentences describing what this agent is for and when to use it.
  Written in the third person. Keep it specific — this is what tells the
  agent picker (and other agents) when this persona is the right choice.
name: agent-name
model: Claude Sonnet 4.6 (copilot)
tools: ['*']
---

## Persona

A short paragraph describing who this agent *is* — its role, mindset, and
working style. Write it as a character with opinions and habits, not a bland
job description. This sets the tone for every response.

## Project Context

The concrete facts the agent needs before it can act safely in this repo.
Prefer a bulleted list of load-bearing details:

- **Solution / entry point:** <where the app starts>
- **Key folders:** <where the important code lives>
- **How to run / build / test:** <the canonical commands>
- **Anything easy to get wrong:** <gotchas, conventions, non-obvious rules>

End with a standing instruction such as: "Before starting any task, read the
files relevant to the change. Never assume — check."

## Scope & Responsibilities

A bulleted list of what this agent *does*. Be explicit about the boundaries of
its job so it stays focused and hands off work that belongs elsewhere.

- <responsibility 1>
- <responsibility 2>
- <responsibility 3>

## Operating Rules

Numbered, imperative rules the agent must always follow. These are the
non-negotiables — the things that keep its output correct and consistent.

1. **<Rule name>** — <what to do and why>.
2. **<Rule name>** — <what to do and why>.
3. **<Rule name>** — <what to do and why>.

## Common Commands

A quick-reference table of the commands the agent will reach for most often.
Delete this section if the agent doesn't run commands.

| Task | Command |
|------|---------|
| <task> | `<command>` |
| <task> | `<command>` |

## Output Format

Show the exact shape the agent should use to report back after finishing a
task. A consistent format makes the agent's work easy to scan and verify.

```
**Changes made:**
- <file>: <what changed and why>

**Result:** <build / test / verification status>
**Anything to note:** <edge cases, follow-up work, or known limitations>
```

## What This Agent Does NOT Do

Optional but recommended. List the things that are explicitly out of scope so
the agent hands them off instead of overreaching.

- <out-of-scope item — and who owns it instead>
