# CR-026 — RXTA-Owned UAT Environment Script Governance

## Status

Proposed for v0.2.2

## Objective

Move UAT/deployment environment scripts out of `relix.git` and into RXTA / `relix-tool`, so runtime code remains product-owned while UAT setup remains test-governance-owned.

## Scope

RXTA owns scripts such as:

* `install_storage.sh`
* `setup_uat_storage.sh`
* `cleanup_phase2_storage.sh`

## Required Architecture

```text
relix-tool / RXTA
  owns UAT setup scripts
  deploys scripts to relix-vm
  executes setup/cleanup during UAT

relix.git
  owns runtime/product code only
  does not own UAT infra scripts
```

## Rules

* Runtime repo must not depend on UAT scripts.
* RXTA may copy scripts to the remote Relix VM during deployment.
* Scripts must be versioned with RXTA.
* Scripts must be idempotent where possible.
* Unsupported backends must report `SKIPPED`, not fail.
* Deploy logs must show script execution status.

## Acceptance Criteria

* UAT storage scripts exist under RXTA repo.
* `relix-deploy` can deploy/run them on `relix-vm`.
* `relix.git` no longer needs UAT infra scripts.
* Repeated UAT setup is safe.
* Cleanup/reset behavior is explicit and auditable.
