#!/usr/bin/env bash
set -euo pipefail

GITHUB_BASE="https://github.com/bharatbs13"

REPO_GIT="$1"
BRANCH="$2"
SRC_PATH="$3"
MODE="${4:-}"

shift 4 || true
ITEMS=("$@")

if [ -z "$REPO_GIT" ] || [ -z "$BRANCH" ] || [ -z "$SRC_PATH" ] || [ -z "$MODE" ]; then
  echo "Usage: ./smart_partial_sync.sh <repo_git> <branch> <src_path> <--dry-run|--apply> <item1> [item2...]"
  exit 1
fi

if [ "$MODE" != "--dry-run" ] && [ "$MODE" != "--apply" ]; then
  echo "Mode must be --dry-run or --apply"
  exit 1
fi

if [ ${#ITEMS[@]} -eq 0 ]; then
  echo "No files/folders provided to sync."
  exit 1
fi

REPO_DIR="${REPO_GIT%.git}"
REPO_URL="$GITHUB_BASE/$REPO_GIT"
COMMIT_MSG="partial sync: selected files from package_src to ${BRANCH}"

if [ ! -d "$SRC_PATH" ]; then
  echo "Source path does not exist: $SRC_PATH"
  exit 1
fi

if [ "$(basename "$SRC_PATH")" != "package_src" ]; then
  echo "SRC root folder must be named: package_src"
  exit 1
fi

case "$BRANCH" in
  main|master)
    echo "Refusing to sync directly to protected branch: $BRANCH"
    exit 1
    ;;
esac

count_files() {
  local path="$1"
  if [ -d "$path" ]; then
    find "$path" -type f | wc -l | tr -d ' '
  elif [ -f "$path" ]; then
    echo "1"
  else
    echo "0"
  fi
}

show_snapshot() {
  local label="$1"
  local path="$2"

  echo ""
  echo "===== $label: $path ====="

  if [ ! -e "$path" ]; then
    echo "Path does not exist"
    return
  fi

  echo "File count: $(count_files "$path")"

  if [ -d "$path" ]; then
    find "$path" -maxdepth 3 -type f | sort | head -50
  else
    ls -l "$path"
  fi
}

resolve_target_path() {
  local item="$1"
  local base
  base="$(basename "$item")"

  if [ -e "$item" ]; then
    echo "$item"
    return
  fi

  if [[ "$item" == */* ]]; then
    echo "$item"
    return
  fi

  local found_count
  found_count="$(find . -path "./.git" -prune -o -name "$base" -print | wc -l | tr -d ' ')"

  if [ "$found_count" -eq 1 ]; then
    find . -path "./.git" -prune -o -name "$base" -print | sed 's#^\./##'
    return
  fi

  if [ "$found_count" -gt 1 ]; then
    echo "ERROR: Ambiguous target name: $base" >&2
    find . -path "./.git" -prune -o -name "$base" -print >&2
    exit 1
  fi

  echo "$base"
}

echo "Removing old clone..."
rm -rf "$REPO_DIR"

echo "Cloning $REPO_URL branch $BRANCH ..."
git clone --branch "$BRANCH" "$REPO_URL" "$REPO_DIR"

cd "$REPO_DIR"

echo "Current branch:"
git branch --show-current

RSYNC_FLAGS=(-av)

if [ "$MODE" = "--dry-run" ]; then
  RSYNC_FLAGS+=(--dry-run)
  echo "Running in DRY RUN mode..."
else
  echo "Running in APPLY mode..."
fi

SYNCED_PATHS=()

for item in "${ITEMS[@]}"; do
  SRC_ITEM="$SRC_PATH/$item"

  if [ ! -e "$SRC_ITEM" ]; then
    echo "Missing in package_src: $SRC_ITEM"
    exit 1
  fi

  TARGET_PATH="$(resolve_target_path "$item")"

  echo ""
  echo "Syncing:"
  echo "  source: $SRC_ITEM"
  echo "  target: $TARGET_PATH"

  show_snapshot "BEFORE target" "$TARGET_PATH"
  show_snapshot "SOURCE" "$SRC_ITEM"

  if [ -d "$SRC_ITEM" ]; then
    mkdir -p "$TARGET_PATH"
    rsync "${RSYNC_FLAGS[@]}" --delete \
      --exclude ".git/" \
      --exclude ".venv/" \
      --exclude "__pycache__/" \
      --exclude ".pytest_cache/" \
      "$SRC_ITEM"/ "$TARGET_PATH"/
  else
    mkdir -p "$(dirname "$TARGET_PATH")"
    rsync "${RSYNC_FLAGS[@]}" \
      "$SRC_ITEM" "$TARGET_PATH"
  fi

  show_snapshot "AFTER target" "$TARGET_PATH"

  SYNCED_PATHS+=("$TARGET_PATH")
done

echo ""
echo "Git status after sync:"
git status --short

if [ "$MODE" = "--dry-run" ]; then
  echo "Dry run complete. No commit made."
  cd ..
  rm -rf "$REPO_DIR"
  exit 0
fi

if [ -z "$(git status --porcelain)" ]; then
  echo "No changes to commit."
  cd ..
  rm -rf "$REPO_DIR"
  exit 0
fi

git add -A "${SYNCED_PATHS[@]}"

echo ""
echo "Staged changes:"
git diff --cached --stat

git commit -m "$COMMIT_MSG"

LOCAL_COMMIT="$(git rev-parse HEAD)"

git push origin "$BRANCH"

echo ""
echo "Verifying push..."
git fetch origin "$BRANCH"

REMOTE_COMMIT="$(git rev-parse "origin/$BRANCH")"

if [ "$LOCAL_COMMIT" != "$REMOTE_COMMIT" ]; then
  echo "ERROR: Push verification failed."
  echo "Local : $LOCAL_COMMIT"
  echo "Remote: $REMOTE_COMMIT"
  exit 1
fi

echo "Push verified."
echo "Committed and pushed:"
git log -1 --oneline

echo ""
echo "Final clean status check:"
git status --short

cd ..

echo "Deleting fresh clone..."
rm -rf "$REPO_DIR"

echo "Done. Selected files/folders synced and verified on $BRANCH."
