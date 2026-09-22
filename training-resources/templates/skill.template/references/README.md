# references/

Place detailed documentation here that the agent loads on demand — material
that is too long or too specialised to live inside `SKILL.md` itself.

## When to use a reference file

- The topic is only relevant for a subset of the skill's tasks.
- The detail would push `SKILL.md` past ~500 lines / ~5 000 tokens.
- You want to keep `SKILL.md` focused while making depth available when needed.

## How to reference from SKILL.md

Be explicit — tell the agent *when* to load the file, not just that it exists:

```markdown
Read `references/advanced-config.md` before attempting step 4.
```

Avoid vague phrases like "see references/ for more detail" — the agent may
never look.

## Keep files focused

One topic per file. Agents load entire files into context, so smaller and
more focused files mean less unnecessary token use.

## Delete this folder

If your skill does not need any reference files, delete this directory.
