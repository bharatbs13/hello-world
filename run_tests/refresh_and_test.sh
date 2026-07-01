#!/usr/bin/env bash
set -e

GITHUB_BASE="https://github.com/bharatbs13"

REPO_GIT="$1"
BRANCH="$2"
TEST_PATH="$3"

if [ -z "$REPO_GIT" ] || [ -z "$BRANCH" ] || [ -z "$TEST_PATH" ]; then
  echo "Usage: ./refresh_and_test.sh <repo_git> <branch> <test_path>"
  echo "Example:"
  echo "./refresh_and_test.sh helixlab.git dev/v1.0 tests"
  exit 1
fi

REPO_DIR="${REPO_GIT%.git}"
REPO_URL="$GITHUB_BASE/$REPO_GIT"

echo "Removing old clone if exists..."
rm -rf "$REPO_DIR"

echo "Cloning $REPO_URL ..."
git clone "$REPO_URL" "$REPO_DIR"

cd "$REPO_DIR"

echo "Checking out branch: $BRANCH"
git checkout "$BRANCH"

echo "Selecting Python..."

if [ -n "${PYTHON_BIN:-}" ]; then
  if [ ! -x "$PYTHON_BIN" ]; then
    echo "PYTHON_BIN is set but not executable: $PYTHON_BIN"
    exit 1
  fi
elif command -v python3.12 >/dev/null 2>&1; then
  PYTHON_BIN="python3.12"
elif command -v python3.11 >/dev/null 2>&1; then
  PYTHON_BIN="python3.11"
else
  PYTHON_BIN="python3"
fi

echo "Using Python: $("$PYTHON_BIN" --version)"

echo "Creating virtual environment..."
"$PYTHON_BIN" -m venv .venv
source .venv/bin/activate

echo "Upgrading pip..."
python -m pip install --upgrade pip

echo "Installing dependencies..."

if [ -f "requirements.txt" ]; then
  echo "Found requirements.txt"
  python -m pip install -r requirements.txt
fi

if [ -f "requirements-dev.txt" ]; then
  echo "Found requirements-dev.txt"
  python -m pip install -r requirements-dev.txt
fi

if [ ! -f "requirements.txt" ] && [ ! -f "requirements-dev.txt" ]; then
  echo "No requirements file found. Installing pytest only."
  python -m pip install pytest
fi

echo "Installing package..."
if [ -f "pyproject.toml" ] || [ -f "setup.py" ]; then
  python -m pip install -e .
else
  export PYTHONPATH="$(pwd):${PYTHONPATH:-}"
fi

echo "Running tests..."
pytest "$TEST_PATH"

cd ..

echo "Cleaning up clone..."
rm -rf "$REPO_DIR"

echo "Done."
