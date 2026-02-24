---
name: gh-pr-creator
description: "Creates a GitHub Pull Request using the gh CLI. Use when the user wants to create a PR and the `gh` CLI is available."
---

# GitHub Pull Request Creator

This skill automates the creation of a GitHub Pull Request using the `gh` command-line tool.

## Workflow

1.  **Verify `gh` CLI:** First, check if `gh` is installed and authenticated by running `gh auth status`. If it's not available or not authenticated, inform the user and stop.
2.  **Execute the Script:** If `gh` is available, execute the `scripts/create-pr.sh` script.
3.  **Provide a Link:** The script will output the URL of the newly created Pull Request. Present this URL to the user.

## Bundled Resources

-   **`scripts/create-pr.sh`**: A shell script that encapsulates the entire PR creation logic:
    -   Detects the default branch (e.g., `main`) and the current branch.
    -   Gathers all commit messages between the default and current branch.
    -   Uses the latest commit message for the PR title.
    -   Formats the collected commit messages as a detailed PR body.
    -   Calls `gh pr create` with the prepared title, body, and branches.