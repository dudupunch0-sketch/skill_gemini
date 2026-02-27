---
name: git-push
description: Push the current branch to a remote with `git push`, including first-push upstream setup (`-u`) and common push failure handling. Use when the user asks to push commits/branch changes to a remote.
---

# Git Push

Use this skill when the user wants to push local commits or a branch to a remote via `git push`.

## Scope and Role

- This skill owns **branch push** workflows (`git push`).
- It may set upstream on first push (`git push -u <remote> <branch>`).
- It does not replace:
  - `gh-pr-creator` for pull request creation
  - `git-identity-fixer` for commit identity errors during `git commit`

## Workflow

1. Confirm the current repo and branch:
   - `git rev-parse --show-toplevel`
   - `git branch --show-current`
2. Inspect local state and remotes:
   - `git status --short`
   - `git remote -v`
3. Prefer a non-interactive, explicit push command.
4. If upstream exists, push to upstream (usually `git push` or explicit `git push <remote> <branch>`).
5. If upstream does not exist and the user did not specify otherwise, prefer:
   - `git push -u origin <current-branch>`
   - If `origin` does not exist, choose an existing remote (or ask the user if multiple remotes exist and intent is unclear).
6. Return the exact push command used and the result (remote/branch/upstream set or not).

## Failure Handling

- **Non-fast-forward rejected**: do not force-push unless the user explicitly asks. Explain that remote has new commits and surface the rejection.
- **Auth/permission errors**: surface the error and stop; do not loop.
- **No commits / everything up-to-date**: report that nothing new was pushed.
- **Protected branch / hook rejection**: surface the server or hook message verbatim (briefly) and stop.

## Codex Notes

- Prefer explicit branch names over relying on implicit push defaults when setting upstream.
- Avoid `--force` / `--force-with-lease` unless explicitly requested.
- If the user names a remote or branch, use those exact values.
- If push is a prerequisite for PR creation, complete push first, then hand off to `gh-pr-creator` if asked.
