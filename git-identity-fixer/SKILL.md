---
name: git-identity-fixer
description: Fix 'Author identity unknown' git commit failures by setting a temporary repository-local identity and retrying the commit.
---

# Git Identity Fixer

Use this skill when a `git commit` fails because Git user identity is not configured.

## Trigger

- `git commit` exits with code `128`, and stderr contains:
  - `Author identity unknown`, or
  - `Please tell me who you are.`

## Workflow

1. Confirm this is specifically an identity error (not another commit failure).
2. Set a temporary **local** identity for the current repo only:

```bash
git config --local user.name "Codex CLI"
git config --local user.email "codex-cli@openai.local"
```

3. Retry the exact same `git commit` command once.
4. After the original task finishes, tell the user that a repo-local temporary identity was set and suggest configuring a global identity.

## Codex Notes

- Never use `--global` for this workaround unless the user explicitly asks.
- If one of `user.name` or `user.email` is already configured locally, only set the missing field.
- If the retry still fails, surface the new error instead of looping.
- Mention the repo-local config change in the final response for transparency.
