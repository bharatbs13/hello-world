# FR-064 — Controlled `dlt` Governance & Access Framework

## Status

Proposed

## Phase

`v0.2.1`

## Objective

Provide a controlled governance and access framework for `dlt` integration within Relix using a centralized controller, YAML-configured source/destination registration, and deterministic runtime enforcement.

FR-064 enables Relix to leverage the broad connector ecosystem provided by `dlt` while preserving Relix runtime determinism, governance, security, and execution integrity.

---

## Scope

FR-064 introduces:

* `RelixDltController`
* YAML-configured source/destination registration
* access-control enforcement
* connector governance
* secret-provider integration
* controlled `dlt` pipeline creation
* preflight validation for `dlt`-backed connectors

FR-064 does NOT replace Relix connector interfaces or runtime orchestration.

---

## Architectural Principle

```text
dlt = connector capability provider
Relix = governance + determinism layer
```

Relix MUST remain authoritative for:

* runtime orchestration
* deterministic execution
* checkpoints
* reconciliation
* execution plans
* event lifecycle semantics
* protocol semantics

---

## Connector Ecosystem Model

All connector types supported by `dlt` are implicitly available.

Relix MUST NOT maintain a duplicated registry of supported connector types.

Instead, Relix governs:

* which configured sources may be used
* which configured destinations may be used
* which tables/schemas are accessible
* whether execution policies are satisfied

---

## Architecture

```text
                ┌────────────────────┐
                │ Relix Runtime Core │
                └─────────┬──────────┘
                          │
                RelixDltController
                          │
            ┌─────────────┴─────────────┐
            │                           │
      Access Governance          Secret Provider
            │                           │
            └─────────────┬─────────────┘
                          │
                     dlt Backend
```

---

## RelixDltController

### Responsibilities

The controller MUST:

* validate source registration
* validate destination registration
* enforce table governance
* enforce access policies
* construct `dlt` pipelines
* integrate with Relix secret providers
* isolate raw `dlt` APIs from runtime layers

---

## Runtime Isolation

Relix runtime MUST NOT directly invoke raw `dlt` APIs.

The following pattern is prohibited:

```python
dlt.pipeline(...)
```

All `dlt` interactions MUST occur through:

```python
RelixDltController
```

---

## YAML Configuration

### Example

```yaml
dlt:
  enabled: true

  sources:
    - id: sales_pg
      type: postgres
      secret_ref: relix/secrets/sales_pg

      allowed_tables:
        - public.orders
        - public.customers

  destinations:
    - id: warehouse_duckdb
      type: duckdb
      dataset_name: relix_snapshot
      secret_ref: relix/secrets/duckdb

  access_policy:
    allow_raw_sql: false
    allow_unlisted_tables: false
    require_preflight: true
```

---

## Source & Destination Governance

Relix MUST validate:

* source existence
* destination existence
* table allowlisting
* schema governance
* credential availability
* runtime policy compliance

before connector execution begins.

---

## Connector Types

Relix MUST NOT maintain a hardcoded allowlist of connector types.

Connector availability is delegated to `dlt`.

Unsupported connector types MUST fail during preflight validation.

---

## Raw SQL Policy

Raw SQL execution MUST be disabled by default.

### Default

```yaml
allow_raw_sql: false
```

---

## Table Governance

The controller MUST validate:

* schema name
* table name
* allowed-table membership

before read or write operations begin.

---

## Secret Handling

Credentials MUST be resolved through Relix secret providers.

The controller MUST NOT:

* hardcode credentials
* bypass Relix secret providers
* expose secrets in logs/events

---

## Preflight Integration

FR-033 preflight MUST validate:

* source accessibility
* destination accessibility
* required permissions
* table governance
* policy compliance
* capability compatibility

Execution MUST NOT begin if governance checks fail.

---

## Determinism Requirements

The controller MUST NOT weaken:

* deterministic ordering
* deterministic pagination
* replay consistency
* reconciliation reproducibility

Relix runtime remains authoritative for all deterministic execution semantics.

---

## Reconciliation

Reconciliation MUST remain Relix-owned.

The controller MAY expose helper metadata:

* counts
* checksums
* destination statistics

but reconciliation decisions MUST remain inside Relix runtime.

---

## Error Semantics

`dlt`-originated failures MUST be translated into Relix runtime errors.

Raw `dlt` exceptions MUST NOT propagate beyond connector boundaries.

---

## Packaging

`dlt` MUST remain an optional dependency.

### Example

```text
pip install relix[dlt]
```

Core Relix installation MUST NOT require `dlt`.

---

## Connector Selection Policy

Default selection policy:

1. Native connector
2. `DltConnectorAdapter`
3. Fail if no compatible connector exists

---

## Auditability

The controller SHOULD emit audit events for:

* connector selection
* unauthorized source access
* unauthorized destination access
* unauthorized table requests
* failed preflight validation
* connector capability mismatches

---

## Acceptance Criteria

FR-064 is complete when:

* `RelixDltController` exists
* YAML source/destination registration exists
* access policies are enforced
* secret-provider integration works
* unauthorized table access is rejected
* preflight validates governance policies
* raw `dlt` access is isolated behind controller boundaries
* at least one `dlt`-backed connector path is tested successfully

---

## Deferred Items

The following are deferred:

* RBAC integration
* user-scoped permissions
* dynamic policy reload
* distributed governance
* streaming connectors
* connector usage quotas
* connector rate limiting
* connector marketplace discovery

---

## References

* FR-032 Ports & Adapters
* FR-033 Preflight Framework
* FR-063 Universal Connector Adapter Framework

:contentReference[oaicite:0]{index=0}
