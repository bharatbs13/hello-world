#!/usr/bin/env bash
set -e

GITHUB_BASE="https://github.com/bharatbs13"

REPO_GIT="$1"
BRANCH="$2"
SRC_PATH="$3"
DRY_RUN="${4:-}"

if [ -z "$REPO_GIT" ] || [ -z "$BRANCH" ] || [ -z "$SRC_PATH" ]; then
  echo "Usage: ./scoped_rsync_only.sh <repo_git> <branch> <src_path> [--dry-run]"
  echo "Example:"
  echo "./scoped_rsync_only.sh relix.git fix/v0.1.1-core-boundary /Users/bharatsharma/Downloads/package_src --dry-run"
  exit 1
fi

REPO_DIR="${REPO_GIT%.git}"
REPO_URL="$GITHUB_BASE/$REPO_GIT"
COMMIT_MSG="Scoped mirror sync to ${BRANCH}"

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

echo "Detecting folders inside package_src..."
SCOPES=()

for item in "$SRC_PATH"/*; do
  if [ -d "$item" ]; then
    SCOPES+=("$(basename "$item")")
  fi
done

if [ ${#SCOPES[@]} -eq 0 ]; then
  echo "No folders found inside package_src to sync."
  exit 1
fi

echo "Scopes to sync:"
for scope in "${SCOPES[@]}"; do
  echo "- $scope/"
done

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
  echo "Running scoped rsync in DRY RUN mode..."
else
  echo "Running scoped rsync in APPLY mode..."
fi

for scope in "${SCOPES[@]}"; do
  echo "Syncing scope: $scope/"
  mkdir -p "$scope"

  rsync $RSYNC_FLAGS \
    --exclude ".venv/" \
    --exclude "__pycache__/" \
    --exclude ".pytest_cache/" \
    "$SRC_PATH/$scope"/ "./$scope/"
done

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

git add -A "${SCOPES[@]}"
git commit -m "$COMMIT_MSG"
git push origin "$BRANCH"

cd ..

echo "Deleting fresh clone..."
rm -rf "$REPO_DIR"

echo "Done. Scoped folders mirrored to $BRANCH."
