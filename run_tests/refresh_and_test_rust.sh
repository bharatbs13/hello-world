#!/usr/bin/env bash
set -e

GITHUB_BASE="https://github.com/bharatbs13"

REPO_GIT="$1"
BRANCH="$2"
RUST_DIR="$3"

if [ -z "$REPO_GIT" ] || [ -z "$BRANCH" ] || [ -z "$RUST_DIR" ]; then
  echo "Usage: ./refresh_and_test_rust.sh <repo_git> <branch> <rust_dir>"
  echo "Example:"
  echo "./refresh_and_test_rust.sh omnitick.git dev/v0.1-data-plane omnitick/data_plane"
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

if [ ! -d "$RUST_DIR" ]; then
  echo "ERROR: Rust directory not found: $RUST_DIR"
  exit 1
fi

cd "$RUST_DIR"

if [ ! -f "Cargo.toml" ]; then
  echo "ERROR: Cargo.toml not found in $RUST_DIR"
  exit 1
fi

echo "Checking Rust formatting..."
cargo fmt --all -- --check

echo "Running clippy..."
cargo clippy --all-targets --all-features -- -D warnings

echo "Running Rust tests..."
cargo test --all-features

cd ../..

echo "Cleaning up clone..."
rm -rf "$REPO_DIR"

echo "Done."
