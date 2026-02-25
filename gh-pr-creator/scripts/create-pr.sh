#!/usr/bin/env bash
set -euo pipefail

draft=0
base_branch=""
declare -a reviewers=()
declare -a assignees=()
declare -a labels=()

usage() {
  cat <<'EOF'
Usage: create-pr.sh [--draft] [--base <branch>]
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --draft)
      draft=1
      shift
      ;;
    --base)
      if [[ $# -lt 2 ]]; then
        echo "Missing value for --base" >&2
        usage >&2
        exit 1
      fi
      base_branch="$2"
      shift 2
      ;;
    --reviewer)
      if [[ $# -lt 2 ]]; then
        echo "Missing value for --reviewer" >&2
        usage >&2
        exit 1
      fi
      reviewers+=("$2")
      shift 2
      ;;
    --assignee)
      if [[ $# -lt 2 ]]; then
        echo "Missing value for --assignee" >&2
        usage >&2
        exit 1
      fi
      assignees+=("$2")
      shift 2
      ;;
    --label)
      if [[ $# -lt 2 ]]; then
        echo "Missing value for --label" >&2
        usage >&2
        exit 1
      fi
      labels+=("$2")
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "Required command not found: $1" >&2
    exit 1
  }
}

require_cmd git
require_cmd gh

git rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
  echo "Not inside a git repository." >&2
  exit 1
}

gh auth status >/dev/null 2>&1 || {
  echo "gh is not authenticated. Run 'gh auth login' first." >&2
  exit 1
}

current_branch="$(git symbolic-ref --quiet --short HEAD 2>/dev/null || true)"
if [[ -z "$current_branch" ]]; then
  echo "Detached HEAD is not supported for PR creation." >&2
  exit 1
fi

detect_default_branch() {
  local detected=""

  detected="$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null | sed 's#^origin/##' || true)"
  if [[ -n "$detected" ]]; then
    printf '%s\n' "$detected"
    return 0
  fi

  detected="$(git remote show origin 2>/dev/null | sed -n '/HEAD branch/s/.*: //p' | head -n1 || true)"
  if [[ -n "$detected" ]]; then
    printf '%s\n' "$detected"
    return 0
  fi

  detected="$(gh repo view --json defaultBranchRef -q '.defaultBranchRef.name' 2>/dev/null || true)"
  if [[ -n "$detected" ]]; then
    printf '%s\n' "$detected"
    return 0
  fi

  return 1
}

if [[ -z "$base_branch" ]]; then
  base_branch="$(detect_default_branch || true)"
fi

if [[ -z "$base_branch" ]]; then
  echo "Could not determine the default/base branch. Use --base <branch>." >&2
  exit 1
fi

if [[ "$current_branch" == "$base_branch" ]]; then
  echo "Current branch '$current_branch' is the base branch. Create a feature branch first." >&2
  exit 1
fi

if ! git rev-parse --abbrev-ref --symbolic-full-name '@{upstream}' >/dev/null 2>&1; then
  echo "Current branch '$current_branch' has no upstream. Push it first (e.g. 'git push -u origin $current_branch')." >&2
  exit 1
fi

base_ref=""
if git show-ref --verify --quiet "refs/remotes/origin/$base_branch"; then
  base_ref="origin/$base_branch"
elif git show-ref --verify --quiet "refs/heads/$base_branch"; then
  base_ref="$base_branch"
else
  echo "Base branch '$base_branch' not found locally. Fetch it or specify another --base branch." >&2
  exit 1
fi

existing_pr_url="$(gh pr list --head "$current_branch" --base "$base_branch" --json url --jq '.[0].url' 2>/dev/null || true)"
if [[ -n "$existing_pr_url" ]]; then
  echo "PR already exists:"
  echo "$existing_pr_url"
  exit 0
fi

merge_base="$(git merge-base "$base_ref" HEAD)"
commits="$(git log --pretty=format:'- %s (%h)' "$merge_base..HEAD")"
if [[ -z "$commits" ]]; then
  echo "No commits to include in a PR relative to '$base_ref'." >&2
  exit 1
fi

pr_title="$(git log -1 --pretty=%s)"

tmp_body="$(mktemp)"
cleanup() {
  rm -f "$tmp_body"
}
trap cleanup EXIT

{
  echo "## Summary"
  echo
  echo "Auto-generated from branch commits by Codex."
  echo
  echo "## Commits"
  echo
  printf '%s\n' "$commits"
} >"$tmp_body"

create_args=(
  pr create
  --title "$pr_title"
  --body-file "$tmp_body"
  --head "$current_branch"
  --base "$base_branch"
)

if [[ "$draft" -eq 1 ]]; then
  create_args+=(--draft)
fi

for reviewer in "${reviewers[@]}"; do
  create_args+=(--reviewer "$reviewer")
done

for assignee in "${assignees[@]}"; do
  create_args+=(--assignee "$assignee")
done

for label in "${labels[@]}"; do
  create_args+=(--label "$label")
done

create_output="$(gh "${create_args[@]}" 2>&1)" || {
  echo "$create_output" >&2
  exit 1
}

pr_url="$(printf '%s\n' "$create_output" | grep -Eo 'https://github\.com/[^[:space:]]+/pull/[0-9]+' | tail -n1 || true)"
if [[ -z "$pr_url" ]]; then
  pr_url="$(gh pr list --head "$current_branch" --base "$base_branch" --json url --jq '.[0].url' 2>/dev/null || true)"
fi

echo "Created PR:"
if [[ -n "$pr_url" ]]; then
  echo "$pr_url"
else
  echo "$create_output"
fi
echo "Title: $pr_title"
echo "Base: $base_branch"
echo "Head: $current_branch"
