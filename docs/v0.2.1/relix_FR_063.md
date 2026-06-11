# FR-034 — Universal Connector Adapter Framework (`dlt` Integration)

## Status

Proposed

## Phase

`v0.2.1`

## Objective

Provide a universal connector adapter mechanism for Relix using `dlt` as an optional connector backend in order to reduce the implementation and maintenance burden of database-specific connectors while preserving Relix deterministic runtime semantics.

This framework allows Relix to support a broad range of source and destination systems without requiring native connector implementations for every database.

---

## Scope

FR-034 introduces:

* Optional `DltConnectorAdapter`
* Connector selection policy
* Native-preferred fallback semantics
* Capability mapping between Relix and `dlt`
* Runtime-safe adapter isolation
* Optional dependency packaging

FR-034 does NOT replace native Relix connectors.

---

## Non-Goals

FR-035 does NOT delegate the following responsibilities to `dlt`:

* deterministic execution orchestration
* execution checkpoints
* reconciliation semantics
* event lifecycle management
* execution plan freezing
* runtime ordering guarantees
* append-only event semantics
* Relix protocol semantics

Relix remains authoritative for all runtime semantics.

---

## Architectural Position

```text
                ┌────────────────────┐
                │ Relix Runtime Core │
                └─────────┬──────────┘
                          │
                 Relix Connector Interface
                          │
        ┌─────────────────┴─────────────────┐
        │                                   │
┌──────────────────┐             ┌────────────────────┐
│ Native Connector │             │ DltConnectorAdapter │
│ (Postgres etc.)  │             │ (universal backend) │
└──────────────────┘             └────────────────────┘
```

---

## Connector Selection Policy

### Default Policy

Relix MUST prefer native connectors when available.

Selection order:

1. Native connector
2. `DltConnectorAdapter`
3. Fail if no compatible connector exists

---

## Configuration

### Example

```yaml
connector_policy:
  mode: native_preferred
  fallback_to_dlt: true
```

### Supported Modes

| Mode | Meaning |
|---|---|
| `native_only` | only native connectors allowed |
| `dlt_only` | force `dlt` adapter |
| `native_preferred` | native first, `dlt` fallback |
| `dlt_fallback` | same as `native_preferred` |

---

## DltConnectorAdapter

### Responsibilities

The adapter MAY use `dlt` for:

* extraction
* loading
* schema discovery
* destination connectivity
* destination abstraction
* incremental loading primitives

---

## Connector Interface Compliance

`DltConnectorAdapter` MUST implement the Relix connector interface.

Required methods include:

* `connect()`
* `disconnect()`
* `validate_permissions()`
* `read_batch()`
* `write_batch()`
* `begin_batch()`
* `commit_batch()`
* `rollback_batch()`
* `discover_schema()`
* `get_capabilities()`

---

## Runtime Isolation

The adapter MUST NOT expose `dlt`-specific semantics into Relix runtime layers.

Relix runtime MUST remain backend-agnostic.

---

## Determinism Requirements

### Ordering

Relix runtime remains responsible for deterministic ordering.

The adapter MUST NOT weaken:

* deterministic pagination
* ordering guarantees
* replay consistency
* reconciliation reproducibility

---

## Reconciliation

Relix reconciliation engine remains authoritative.

The adapter MAY provide helper metadata:

* counts
* checksums
* destination statistics

but reconciliation decisions MUST remain inside Relix runtime.

---

## Execution Plans

Frozen execution plans remain Relix-owned.

The adapter MUST consume execution plans but MUST NOT mutate them.

---

## Packaging

`dlt` MUST remain an optional dependency.

### Example

```text
pip install relix[dlt]
```

Core Relix installation MUST NOT require `dlt`.

---

## Capability Mapping

The adapter MUST expose capability translation between:

* Relix connector capabilities
* `dlt` destination/source capabilities

Unsupported capabilities MUST fail during preflight.

---

## Failure Semantics

Connector failures originating from `dlt` MUST be translated into Relix runtime errors.

Raw `dlt` exceptions MUST NOT propagate beyond connector boundaries.

---

## Security

The adapter MUST support Relix credential providers and MUST NOT bypass Relix secret handling mechanisms.

---

## Acceptance Criteria

FR-034 is complete when:

* `DltConnectorAdapter` exists
* native connector fallback logic exists
* connector selection policy exists
* deterministic ordering guarantees remain intact
* preflight validates adapter capabilities
* reconciliation remains Relix-owned
* optional dependency installation works
* adapter tests pass for at least one non-native destination

---

## Deferred Items

The following are deferred beyond FR-034:

* streaming connectors
* CDC semantics
* bidirectional sync
* async connector execution
* distributed connector orchestration
* connector auto-discovery marketplace

---

## References

* FR-026 Runtime & Execution Framework 
* FR-028 Checkpoint Recovery Framework
* FR-029 Reconciliation Runtime Framework
* FR-030 Immutable Event History 
* FR-032 Application Ports & Adapter Architecture
* FR-033 Preflight Workflow Framework 

