# scripts/

Place executable helpers here that the agent can call during the skill workflow.

## Rules for scripts

- **Self-contained** — document any dependencies clearly at the top of the file.
- **Accept `--help`** — always implement a `--help` flag that explains usage.
- **Idempotent** — running the script twice should produce the same result as running it once.
- **Emit structured output** — write data to `stdout`, diagnostics/errors to `stderr`.
- **Helpful error messages** — tell the user what went wrong and how to fix it.

## Reference from SKILL.md

Tell the agent explicitly when to run a script:

```markdown
Run the setup script before step 3:

    scripts/setup.py --env development
```

Do not just list the script and hope the agent notices it.

## Delete this folder

If your skill does not need any scripts, delete this directory.
