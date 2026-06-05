#!/usr/bin/env bash
set -e

GITHUB_BASE="https://github.com/bharatbs13"

REPO_GIT="$1"
BRANCH="$2"
SRC_PATH="$3"
MODE="$4"

shift 4 || true
ITEMS=("$@")

if [ -z "$REPO_GIT" ] || [ -z "$BRANCH" ] || [ -z "$SRC_PATH" ] || [ -z "$MODE" ]; then
  echo "Usage: ./smart_partial_sync.sh <repo_git> <branch> <src_path> <--dry-run|--apply> <item1> [item2...]"
  echo "Example:"
  echo "./smart_partial_sync.sh relix.git dev/v0.2-runtime /Users/bharatsharma/Downloads/package_src --dry-run executor/runner.py"
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

echo "Removing old clone..."
rm -rf "$REPO_DIR"

echo "Cloning $REPO_URL branch $BRANCH ..."
git clone --branch "$BRANCH" "$REPO_URL" "$REPO_DIR"

cd "$REPO_DIR"

RSYNC_FLAGS=(-av)

if [ "$MODE" = "--dry-run" ]; then
  RSYNC_FLAGS+=(--dry-run)
  echo "Running in DRY RUN mode..."
else
  echo "Running in APPLY mode..."
fi

find_matches_by_name() {
  local name="$1"
  find . \
    -path "./.git" -prune -o \
    -name "$name" -print | sed 's#^\./##'
}

find_matches_by_dirname() {
  local dirname="$1"
  find . \
    -path "./.git" -prune -o \
    -type d -name "$dirname" -print | sed 's#^\./##'
}

resolve_target_path() {
  local item="$1"
  local base
  local first_segment
  local parent_path
  local parent_base

  base="$(basename "$item")"
  first_segment="${item%%/*}"
  parent_path="$(dirname "$item")"
  parent_base="$(basename "$parent_path")"

  # 1. Exact path exists
  if [ -e "$item" ]; then
    echo "$item"
    return
  fi

  # 2. Basename exists uniquely
  mapfile -t name_matches < <(find_matches_by_name "$base")

  if [ ${#name_matches[@]} -eq 1 ]; then
    echo "${name_matches[0]}"
    return
  fi

  if [ ${#name_matches[@]} -gt 1 ]; then
    echo "ERROR: Ambiguous basename target for: $item" >&2
    printf '%s\n' "${name_matches[@]}" >&2
    exit 1
  fi

  # 3. First path segment maps to unique existing repo folder
  if [[ "$item" == */* ]]; then
    mapfile -t first_matches < <(find_matches_by_dirname "$first_segment")

    if [ ${#first_matches[@]} -eq 1 ]; then
      echo "${first_matches[0]}/${item#*/}"
      return
    fi

    if [ ${#first_matches[@]} -gt 1 ]; then
      echo "ERROR: Ambiguous first-segment target for: $item" >&2
      printf '%s\n' "${first_matches[@]}" >&2
      exit 1
    fi
  fi

  # 4. Parent folder maps uniquely
  if [ "$parent_path" != "." ]; then
    mapfile -t parent_matches < <(find_matches_by_dirname "$parent_base")

    if [ ${#parent_matches[@]} -eq 1 ]; then
      echo "${parent_matches[0]}/$base"
      return
    fi

    if [ ${#parent_matches[@]} -gt 1 ]; then
      echo "ERROR: Ambiguous parent-folder target for: $item" >&2
      printf '%s\n' "${parent_matches[@]}" >&2
      exit 1
    fi
  fi

  # 5. No safe match: create using given path from repo root
  echo "$item"
}

SYNCED_PATHS=()

echo "Resolving sync targets..."

for item in "${ITEMS[@]}"; do
  SRC_ITEM="$SRC_PATH/$item"

  if [ ! -e "$SRC_ITEM" ]; then
    echo "Missing in package_src: $SRC_ITEM"
    exit 1
  fi

  TARGET_PATH="$(resolve_target_path "$item")"

  echo "- $item -> $TARGET_PATH"

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

  SYNCED_PATHS+=("$TARGET_PATH")
done

if [ "$MODE" = "--dry-run" ]; then
  echo "Dry run complete. No commit made."
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

git add -A "${SYNCED_PATHS[@]}"
git commit -m "$COMMIT_MSG"
git push origin "$BRANCH"

cd ..

echo "Deleting fresh clone..."
rm -rf "$REPO_DIR"

echo "Done. Selected files/folders synced to $BRANCH."
