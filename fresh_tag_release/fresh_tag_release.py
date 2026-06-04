#!/usr/bin/env python3

import argparse
import getpass
import json
import re
import shutil
import subprocess
import sys
import urllib.error
import urllib.request
from pathlib import Path


GITHUB_BASE = "https://github.com"
GITHUB_API = "https://api.github.com"
OWNER = "bharatbs13"


def run(cmd, cwd=None):
    print("+", " ".join(cmd))
    subprocess.run(cmd, cwd=cwd, check=True)


def extract_version(tag_name: str) -> str:
    match = re.search(r"v\d+\.\d+\.\d+[A-Za-z0-9.-]*", tag_name)
    return match.group(0) if match else ""


def github_api(method, url, token, payload=None):
    data = None
    headers = {
        "Authorization": f"Bearer {token}",
        "Accept": "application/vnd.github+json",
        "X-GitHub-Api-Version": "2022-11-28",
    }

    if payload is not None:
        data = json.dumps(payload).encode("utf-8")
        headers["Content-Type"] = "application/json"

    req = urllib.request.Request(url, data=data, headers=headers, method=method)

    try:
        with urllib.request.urlopen(req) as resp:
            body = resp.read().decode("utf-8")
            return resp.status, json.loads(body) if body else {}
    except urllib.error.HTTPError as e:
        body = e.read().decode("utf-8")
        raise RuntimeError(f"GitHub API failed: {e.code}\n{body}") from e


def main():
    parser = argparse.ArgumentParser(
        description="Create a fresh Git tag and GitHub release using a PAT.",
        epilog=(
            "Example:\n"
            "./fresh_tag_release.py relix.git core-protocol-v0.1.1 "
            '"Relix v0.1.1" RELEASE_NOTES_v0.1.1.md'
        ),
        formatter_class=argparse.RawTextHelpFormatter,
    )

    parser.add_argument("repo_git", help="Repository name, example: relix.git")
    parser.add_argument("tag_name", help="Tag name, example: core-protocol-v0.1.1")
    parser.add_argument("release_title", help='Release title, example: "Relix v0.1.1"')
    parser.add_argument("notes_file", help="Release notes file, example: RELEASE_NOTES_v0.1.1.md")
    parser.add_argument("--branch", default="main", help="Branch to tag from. Default: main")
    parser.add_argument(
        "--stable",
        action="store_true",
        help="Create as stable release instead of prerelease.",
    )

    args = parser.parse_args()

    notes_path = Path(args.notes_file)

    if not notes_path.exists():
        print(f"ERROR: Notes file not found: {notes_path}")
        sys.exit(1)

    version = extract_version(args.tag_name)
    if version and version not in notes_path.name:
        print(f"ERROR: Notes file name must contain version: {version}")
        print(f"Given notes file: {notes_path.name}")
        print(f"Example: RELEASE_NOTES_{version}.md")
        sys.exit(1)

    username = input("GitHub username: ").strip()
    token = getpass.getpass("GitHub token/PAT: ").strip()

    if not username or not token:
        print("ERROR: username/token required")
        sys.exit(1)

    repo_name = args.repo_git.removesuffix(".git")
    repo_dir = Path(repo_name)

    if repo_dir.exists():
        shutil.rmtree(repo_dir)

    auth_repo_url = f"https://{username}:{token}@github.com/{OWNER}/{args.repo_git}"

    try:
        run(["git", "clone", auth_repo_url, repo_name])
        run(["git", "checkout", args.branch], cwd=repo_dir)
        run(["git", "pull", "origin", args.branch], cwd=repo_dir)

        local_tags = subprocess.run(
            ["git", "tag", "--list", args.tag_name],
            cwd=repo_dir,
            capture_output=True,
            text=True,
            check=True,
        ).stdout.strip()

        if local_tags:
            print(f"Tag already exists locally: {args.tag_name}")
        else:
            run(["git", "tag", "-a", args.tag_name, "-m", args.release_title], cwd=repo_dir)

        remote_tags = subprocess.run(
            ["git", "ls-remote", "--tags", "origin", args.tag_name],
            cwd=repo_dir,
            capture_output=True,
            text=True,
            check=True,
        ).stdout.strip()

        if remote_tags:
            print(f"Tag already exists on remote: {args.tag_name}")
        else:
            run(["git", "push", "origin", args.tag_name], cwd=repo_dir)

        notes = notes_path.read_text(encoding="utf-8")

        release_url = f"{GITHUB_API}/repos/{OWNER}/{repo_name}/releases"

        payload = {
            "tag_name": args.tag_name,
            "target_commitish": args.branch,
            "name": args.release_title,
            "body": notes,
            "draft": False,
            "prerelease": not args.stable,
        }

        try:
            _, response = github_api("POST", release_url, token, payload)
            print(f"Release created: {response.get('html_url')}")
        except RuntimeError as e:
            if "already_exists" in str(e) or "Validation Failed" in str(e):
                print(f"Release may already exist for tag: {args.tag_name}")
            else:
                raise

        print(f"Done. Release ready: {args.tag_name}")

    finally:
        if repo_dir.exists():
            shutil.rmtree(repo_dir)


if __name__ == "__main__":
    main()
