#!/usr/bin/env bash
set -e

GITHUB_BASE="https://github.com/bharatbs13"

REPO_GIT="$1"
BRANCH="$2"
SRC_PATH="$3"

if [ -z "$REPO_GIT" ] || [ -z "$BRANCH" ] || [ -z "$SRC_PATH" ]; then
  echo "Usage: ./fresh_sync_commit.sh <repo_git> <branch> <src_path>"
  echo "Example:"
  echo "./fresh_sync_commit.sh relix.git dev/v0.2-runtime /Users/bharatsharma/Downloads/package_src"
  exit 1
fi

REPO_DIR="${REPO_GIT%.git}"
REPO_URL="$GITHUB_BASE/$REPO_GIT"
COMMIT_MSG="Sync files to ${BRANCH}"

if [ ! -d "$SRC_PATH" ]; then
  echo "Source path does not exist: $SRC_PATH"
  exit 1
fi

SRC_BASENAME="$(basename "$SRC_PATH")"

if [ "$SRC_BASENAME" != "package_src" ]; then
  echo "SRC root folder must be named: package_src"
  echo "Provided: $SRC_BASENAME"
  exit 1
fi

echo "Removing old clone..."
rm -rf "$REPO_DIR"

echo "Cloning $REPO_URL ..."
git clone "$REPO_URL" "$REPO_DIR"

cd "$REPO_DIR"

echo "Checking out branch: $BRANCH"
git checkout "$BRANCH"

echo "Copying package_src contents into repo root..."
cp -R "$SRC_PATH"/. .

echo "Git status:"
git status --short

if [ -z "$(git status --porcelain)" ]; then
  echo "No changes to commit."
  cd ..
  rm -rf "$REPO_DIR"
  exit 0
fi

git add .
git commit -m "$COMMIT_MSG"
git push origin "$BRANCH"

cd ..

echo "Deleting fresh clone..."
rm -rf "$REPO_DIR"

echo "Done. Changes pushed to $BRANCH."
