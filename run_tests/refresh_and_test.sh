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

echo "Creating virtual environment..."
python -m venv .venv
source .venv/bin/activate

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
  export PYTHONPATH="$(pwd):$PYTHONPATH"
fi

echo "Running tests..."
pytest "$TEST_PATH"

cd ..

echo "Cleaning up clone..."
rm -rf "$REPO_DIR"

echo "Done."
