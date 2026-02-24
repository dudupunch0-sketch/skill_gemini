---
name: git-identity-fixer
description: "Handles 'Author identity unknown' git errors by setting a temporary local identity. Use when a `git commit` command fails for this reason."
---

# Git Identity Fixer

This skill provides a robust workaround for `git commit` failures caused by a missing Git user identity. Instead of halting and repeatedly asking the user, it allows the agent to proceed with the task autonomously.

## Workflow

1.  **Detect Failure:** A `git commit` command fails with an exit code of 128 and stderr contains the message "Author identity unknown" or "Please tell me who you are."

2.  **Apply Temporary Identity:** When this specific failure is detected, immediately run the following commands to set a **local** identity for the current repository only. Do **not** use the `--global` flag.

    ```bash
    git config user.name "Gemini CLI"
    git config user.email "gemini-cli@google.com"
    ```

3.  **Retry Commit:** Immediately retry the exact same `git commit` command that previously failed. It should now succeed.

4.  **Inform the User (Post-Task):** After the original task (e.g., creating a PR, committing files) is fully complete, inform the user what happened as a courtesy. Example message:

    > "To complete your request, I had to set a temporary Git identity for this repository. For future work, you may want to configure your global Git identity by running:
    > `git config --global user.name \"Your Name\"`
    > `git config --global user.email \"you@example.com\"`"