RXTA-BUG-022-001
Title: Deploy fetch path persists/uses invalid GitHub PAT remote URL and leaks token in logs

Scope: v0.2.2 deploy hardening

Issue:
Initial clone can succeed with PAT, but later deploys fail on existing workspace because origin is stored as https://<PAT>@github.com/..., causing git fetch to request a password non-interactively.

Security impact:
PAT may be stored in git remote and exposed in logs.

Expected:
Deploy must never persist PAT in origin URL. Use clean remote URL plus temporary credential mechanism, and redact token from all output.

Fix target:
relix-deploy deploy Git source resolution for existing repo fetch path.
