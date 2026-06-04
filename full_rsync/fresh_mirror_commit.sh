#!/usr/bin/env bash
set -e

GITHUB_BASE="https://github.com/bharatbs13"

REPO_GIT="$1"
BRANCH="$2"
SRC_PATH="$3"
DRY_RUN="${4:-}"

if [ -z "$REPO_GIT" ] || [ -z "$BRANCH" ] || [ -z "$SRC_PATH" ]; then
  echo "Usage: ./fresh_mirror_commit.sh <repo_git> <branch> <src_path> [--dry-run]"
  echo "Example:"
  echo "./fresh_mirror_commit.sh relix.git dev/v0.2-runtime /Users/bharatsharma/Downloads/package_src --dry-run"
  echo "./fresh_mirror_commit.sh relix.git dev/v0.2-runtime /Users/bharatsharma/Downloads/package_src"
  exit 1
fi

REPO_DIR="${REPO_GIT%.git}"
REPO_URL="$GITHUB_BASE/$REPO_GIT"
COMMIT_MSG="Mirror sync files to ${BRANCH}"

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

if [ ! -f "$SRC_PATH/pyproject.toml" ] && [ ! -d "$SRC_PATH/relix" ]; then
  echo "SRC_PATH does not look like repo-root content."
  echo "Expected at least one of:"
  echo "- $SRC_PATH/pyproject.toml"
  echo "- $SRC_PATH/relix/"
  exit 1
fi

echo "Removing old clone..."
rm -rf "$REPO_DIR"

echo "Cloning $REPO_URL ..."
git clone "$REPO_URL" "$REPO_DIR"

cd "$REPO_DIR"

echo "Checking out branch: $BRANCH"
git checkout "$BRANCH"

RSYNC_FLAGS="-av --delete"

if [ "$DRY_RUN" = "--dry-run" ]; then
  RSYNC_FLAGS="$RSYNC_FLAGS --dry-run"
  echo "Running mirror sync in DRY RUN mode..."
else
  echo "Running mirror sync in APPLY mode..."
fi

rsync $RSYNC_FLAGS \
  --exclude ".git/" \
  --exclude ".venv/" \
  --exclude "__pycache__/" \
  --exclude ".pytest_cache/" \
  "$SRC_PATH"/ ./

if [ "$DRY_RUN" = "--dry-run" ]; then
  echo "Dry run complete. No files changed, no commit made."
  cd ..
  rm -rf "$REPO_DIR"
  exit 0
fi

echo "Git status:"
git status --short

if [ -z "$(git status --porcelain)" ]; then
  echo "No changes to commit."
  cd ..
  rm -rf "$REPO_DIR"
  exit 0
fi

git add -A
git commit -m "$COMMIT_MSG"
git push origin "$BRANCH"

cd ..

echo "Deleting fresh clone..."
rm -rf "$REPO_DIR"

echo "Done. Branch now mirrors package_src: $BRANCH"
