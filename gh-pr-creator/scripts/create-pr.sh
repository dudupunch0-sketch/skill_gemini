#!/bin/bash
set -e

# 1. Get the default branch (main or master)
DEFAULT_BRANCH=$(git remote show origin | grep 'HEAD branch' | cut -d' ' -f5)
if [ -z "$DEFAULT_BRANCH" ]; then
    echo "Could not determine default branch. Exiting."
    exit 1
fi

# 2. Get the current branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [ "$CURRENT_BRANCH" == "$DEFAULT_BRANCH" ]; then
    echo "You are on the default branch ($DEFAULT_BRANCH). Cannot create a PR against itself."
    exit 1
fi

# 3. Get the list of commits between the default branch and the current branch
COMMITS=$(git log $DEFAULT_BRANCH..$CURRENT_BRANCH --pretty=format:"- %s")
if [ -z "$COMMITS" ]; then
    echo "No new commits on branch '$CURRENT_BRANCH' compared to '$DEFAULT_BRANCH'. Nothing to create a PR for."
    exit 1
fi

# 4. Use the title of the top-most commit as the PR title
PR_TITLE=$(git log -1 --pretty=%s)

# 5. Format the commit list as the PR body
PR_BODY="This PR includes the following changes:
$COMMITS"

# 6. Create the pull request using gh CLI
echo "Creating PR for branch '$CURRENT_BRANCH' into '$DEFAULT_BRANCH'..."
echo "Title: $PR_TITLE"
echo "Body:"
echo "$PR_BODY"

gh pr create --title "$PR_TITLE" --body "$PR_BODY" --head "$CURRENT_BRANCH" --base "$DEFAULT_BRANCH"
