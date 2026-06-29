RXTA-BUG-022-001
Title: Deploy Git auth persists invalid PAT remote URL and leaks token in logs

Severity: High
Type: Functional + Security

Issue:
relix-deploy can store/use GitHub PAT in origin URL as:
https://<PAT>@github.com/<org>/<repo>.git

This breaks existing-repo fetch because Git treats PAT as username and asks for password. It also exposes PAT in deploy logs and git error output.

Expected:
- Never print raw GITHUB_TOKEN / PAT.
- Never store PAT in git remote URL.
- Mask any token-like value in logs.
- Log only:
  GITHUB_TOKEN: set
- Redact URLs as:
  https://***@github.com/...
  or
  https://x-access-token:***@github.com/...

Fix:
Add a deploy log redaction helper and apply it to:
- env/config echo
- remote command logging
- git stdout/stderr
- exception/error messages
- remote URL display

Acceptance:
No deploy output contains `ghp_`, `github_pat_`, or raw token substring.
