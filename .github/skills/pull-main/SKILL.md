---
name: pull-main
description: Pull the latest main from origin and merge it into the current git worktree or branch. Use when the user says a PR was merged, asks to sync with main, pull down latest main, or update the current branch with upstream changes.
license: MIT
---

# Pull Main

Sync the current working branch with the latest `main` from origin. Handles both worktree checkouts and standard single-checkout repositories.

## When to Use

- The user says "merged", "PR merged", or "I've merged it".
- The user asks to "pull down the latest main", "sync with main", or "update my branch".
- After a pull request is merged and the local branch needs upstream changes.

## Workflow

1. **Determine the checkout type.** Check whether the current directory is a linked git worktree or the primary checkout:
   ```bash
   git rev-parse --git-common-dir
   git worktree list
   ```
   If `main` is checked out in a separate worktree (common with worktree-based setups), `git pull origin main` cannot run from the current branch directly — pull it in the checkout that holds `main`.

2. **Pull main.**
   - If `main` lives in another checkout/worktree, pull there:
     ```bash
     cd <main-checkout-path> && git pull origin main
     ```
   - Otherwise, if `main` is the current branch, pull directly:
     ```bash
     git pull origin main
     ```

3. **Merge into the current branch.** If working on a feature branch or worktree, bring the freshly pulled `main` into it:
   ```bash
   git merge main
   ```

4. **Confirm and report.** Confirm the sync completed. If merge conflicts occurred, list the conflicting files and stop for the user to resolve.

## Rules

- Execute automatically without asking for confirmation when the trigger is clear.
- Never force-push or reset — only pull and merge.
- If a merge conflict arises, surface it clearly rather than attempting an automatic resolution.
- Do not operate on unrelated branches; only sync the current working branch with `main`.
