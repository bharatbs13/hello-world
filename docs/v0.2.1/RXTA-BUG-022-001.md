# RXTA-BUG-022-001

**Title**
Deploy Git Authentication Persists Invalid PAT Remote, Leaks Credentials, and Does Not Recover Existing Workspace

**Target Version**
v0.2.1

**Severity**
High

**Type**
Functional + Security + Operational Robustness

## Problem Summary

The deployment workflow does not correctly manage Git authentication and repository state for existing deployments on the Relix VM.

Multiple issues were observed:

1. GitHub PAT is persisted into the repository remote URL.
2. PAT is exposed in deploy logs and Git error messages.
3. Existing repository fetch fails because Git interprets the PAT as the username and requests an interactive password.
4. Deploy assumes an existing repository is always in a clean state and aborts when local modifications prevent branch checkout.

These issues require manual intervention and prevent unattended deployments.

---

## Observed Behaviour

### Authentication

Deploy configures or uses a remote similar to:

```text
https://<PAT>@github.com/<org>/<repo>.git
```

During subsequent deployment:

```bash
git fetch --all --tags
```

fails with:

```text
fatal: could not read Password for 'https://<PAT>@github.com'
```

because Git interprets the PAT as the username.

---

### Credential Exposure

Deploy output exposes sensitive credentials, for example:

```text
https://ghp_xxxxxxxxxxxxxxxxx@github.com/...
```

or equivalent Git error output.

This leaks authentication credentials into:

* console logs
* CI/CD logs
* deployment history
* terminal scrollback

---

### Existing Repository State

If the repository already exists and contains local modifications:

```text
error: Your local changes would be overwritten by checkout
```

deployment aborts without guidance or recovery.

---

## Expected Behaviour

### Git Authentication

Deployment shall:

* never persist PAT inside the Git remote URL
* use a clean repository remote

```text
https://github.com/<org>/<repo>.git
```

* authenticate using a secure temporary mechanism such as:

  * credential helper
  * `.netrc`
  * `GIT_ASKPASS`
  * equivalent non-persistent authentication

---

### Credential Handling

Deploy must never expose authentication secrets.

Environment output should display only:

```text
GITHUB_TOKEN: set
```

or

```text
GITHUB_TOKEN: <configured>
```

Never:

```text
ghp_xxxxx...
github_pat_xxxxx...
```

---

### Log Redaction

All deploy output shall redact secrets, including:

* environment/configuration output
* remote command logging
* Git stdout/stderr
* exception messages
* repository URLs

Example:

```text
https://***@github.com/...
```

or

```text
https://x-access-token:***@github.com/...
```

---

### Existing Workspace Handling

Before checkout, deployment shall detect repository state.

If the repository contains local modifications, deploy should either:

* fail with a clear diagnostic explaining the modified files and recovery options, or
* support an explicit clean option (for example `--force-clean`) that performs:

```bash
git reset --hard
git clean -fd
```

before checkout.

Deploy must never silently overwrite user changes.

---

## Acceptance Criteria

* PAT is never persisted in Git remote configuration.
* PAT never appears in deploy logs.
* `GITHUB_TOKEN` is never printed.
* Existing repositories can be fetched repeatedly without authentication failures.
* Dirty workspaces are detected before checkout.
* Recovery instructions or controlled cleanup are provided.
* Fully automated deployment succeeds without manual Git intervention.
