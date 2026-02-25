---
name: gh-pr-creator
description: Create a GitHub pull request with the `gh` CLI from the current branch. Use when the user asks to open/create/raise a PR and `gh` is available.
---

# GitHub Pull Request Creator

Use this skill when the user wants a GitHub pull request created from the current branch via `gh`.

## Scope and Role

- This skill owns **PR creation** (write action) via `gh pr create`.
- GitHub app tools may overlap on **read/query** tasks (searching PRs, fetching metadata/comments/patches), but they do not replace this creation workflow.
- Prefer a hybrid flow when helpful: app tools for inspection, this skill for creating the PR, app tools again for post-create inspection.

## Workflow

1. Confirm you are in a git repository and on a non-default branch.
2. Verify `gh` is installed and authenticated (`gh auth status`).
3. Prefer non-interactive commands (`gh pr create` with explicit `--title`, `--body-file`, `--base`, `--head`).
4. Run `scripts/create-pr.sh` to generate a PR title/body from branch commits and create the PR.
5. Return the PR URL and a short summary (base/head/title). If a PR already exists for the branch, return that URL instead.

## Codex Notes

- The script is idempotent enough for retries: it checks for an existing PR on the same head/base first.
- If the current branch has no upstream, the script stops and tells you to push first (avoids `gh` interactive prompts).
- If the user explicitly asks for a draft PR, run `scripts/create-pr.sh --draft`.
- If the user names a target base branch, run `scripts/create-pr.sh --base <branch>`.
- If the user names reviewers, assignees, or labels, pass them explicitly with repeated flags:
  - `--reviewer <login>`
  - `--assignee <login>`
  - `--label <name>`
- Do not hardcode default reviewers/assignees/labels in the skill; only add them when the user asks.

## Bundled Resources

- `scripts/create-pr.sh`: Detects base/head, compiles commit summaries, avoids duplicate PRs, and creates the PR using `gh`.
