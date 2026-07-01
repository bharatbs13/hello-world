#!/usr/bin/env bash
set -euo pipefail

GITHUB_BASE="${GITHUB_BASE:-https://github.com/bharatbs13}"

REPO_GIT="${1:-}"
DEV_BRANCH="${2:-}"

if [ -z "$REPO_GIT" ] || [ -z "$DEV_BRANCH" ]; then
  echo "Usage: ./fresh_merge_to_main.sh <repo_git> <dev_branch>"
  echo "Example:"
  echo "./fresh_merge_to_main.sh relix.git dev/v0.2-runtime"
  exit 1
fi

if ! command -v git >/dev/null 2>&1; then
  echo "git not found. Install Xcode Command Line Tools:"
  echo "xcode-select --install"
  exit 1
fi

REPO_DIR="${REPO_GIT%.git}"
REPO_URL="$GITHUB_BASE/$REPO_GIT"
COMMIT_MSG="Merge ${DEV_BRANCH} into main"

echo "Removing old clone..."
rm -rf "$REPO_DIR"

echo "Cloning $REPO_URL ..."
git clone "$REPO_URL" "$REPO_DIR"

cd "$REPO_DIR"

echo "Fetching latest..."
git fetch origin

echo "Checking remote branch exists..."
if ! git ls-remote --exit-code --heads origin "$DEV_BRANCH" >/dev/null 2>&1; then
  echo "Remote branch not found: origin/$DEV_BRANCH"
  exit 1
fi

echo "Checking out main..."
git checkout main
git pull origin main

echo "Merging $DEV_BRANCH into main..."
if ! git merge --no-ff "origin/$DEV_BRANCH" -m "$COMMIT_MSG"; then
  echo ""
  echo "Merge conflict detected."
  echo "Resolve manually. Clone kept at: $(pwd)"
  echo "Conflicted files:"
  git diff --name-only --diff-filter=U
  exit 1
fi

echo "Pushing main..."
git push origin main

cd ..

echo "Deleting fresh clone..."
rm -rf "$REPO_DIR"

echo "Done. ${DEV_BRANCH} merged into main."
