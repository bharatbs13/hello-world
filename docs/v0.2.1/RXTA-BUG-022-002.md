RXTA-BUG-022-002
Title: Branch deploy does not force workspace to latest origin branch head

Issue:
relix-deploy fetches the remote branch but can leave the existing local branch stale. As a result, deployment reports success but relix-vm may still contain older scripts/files.

Expected:
For branch deploy, relix-deploy should ensure:

git fetch origin
git checkout <branch>
git reset --hard origin/<branch>
git clean -fd

or equivalent safe controlled behavior.

Acceptance:
After deploy, relix-vm HEAD must equal origin/<relix-ref>.
