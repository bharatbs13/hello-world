# FR-034 — Universal Connector Adapter Framework

## Phase

**v0.2.1**

## Objective

Provide a universal connector adapter framework that allows Relix to integrate third-party connector ecosystems while preserving Relix deterministic runtime semantics.

The initial adapter implementation for FR-034 is `DltConnectorAdapter`.

---

# Scope

FR-034 introduces:

- Universal connector adapter framework
- Connector selection policy
- Adapter registry
- Supported Connector Registry
- Connector resolution
- Connector resolution stickiness
- Adapter enablement policy
- Native-preferred fallback semantics
- Capability mapping between Relix and adapter ecosystems
- Runtime-safe adapter isolation
- Optional dependency packaging

### Initial Implementation

- `DltConnectorAdapter`

FR-034 does **NOT** replace native Relix connectors.

Native connectors remain first-class connector implementations within Relix.

---

# Non-Goals

FR-034 does **NOT** delegate the following responsibilities to third-party adapters:

- deterministic execution orchestration
- execution checkpoints
- reconciliation semantics
- event lifecycle management
- execution plan freezing
- runtime ordering guarantees
- append-only event semantics
- Relix protocol semantics

Relix remains authoritative for all runtime semantics.

---

# Architectural Position

FR-034 extends the connector framework established by FR-025.

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
│ Native Connector │             │ Adapter Framework  │
│ (Postgres etc.)  │             │ (DltConnectorAdapter│
│                  │             │       v1)          │
└──────────────────┘             └────────────────────┘
```

Future adapter implementations (Airbyte, Singer/Meltano, custom SDKs, etc.) may be added in later releases.

---

# Connector Selection Policy

## Default Policy

Relix MUST prefer native connectors when available.

Selection order:

1. Native connector
2. Compatible adapter connector
3. Fail if no compatible connector exists

---

# Configuration

Example:

```yaml
connector_policy:
  mode: native_preferred
  allow_adapter_connectors: true
```

## Supported Modes

| Mode | Meaning |
|--------|----------|
| `native_only` | only native connectors allowed |
| `adapter_only` | only adapter-backed connectors allowed |
| `native_preferred` | native first, adapter fallback |
| `adapter_preferred` | adapter first, native fallback |

---

# Adapter Registry

Relix maintains a registry of supported adapter implementations.

Example:

```yaml
adapter_registry:
  dlt:
    enabled: true

  airbyte:
    enabled: false

  singer_meltano:
    enabled: false
```

Multiple adapter implementations may coexist within the same Relix deployment.

Adapter registration does not imply adapter enablement.

Only enabled adapters may participate in connector resolution.

---

# Supported Connector Registry

The Supported Connector Registry applies to both native connectors and adapter-backed connectors.

Adapter-backed connectors do not automatically become supported Relix connectors.

Relix explicitly controls which connectors are exposed as supported connectors.

Example:

```yaml
supported_connectors:
  postgres:
    enabled: true

  mysql:
    enabled: true

  snowflake:
    enabled: true
```

Adapter capability does not imply Relix support.

A connector is considered supported only when:

- the adapter supports it (if adapter-backed)
- Relix enables it
- preflight validation succeeds

---

# Connector Resolution

Relix resolves a logical connector into a specific connector implementation.

Resolution flow:

```text
Requested Connector
          ↓
Supported Connector Registry
          ↓
Enabled Adapter Registry
          ↓
Connector Selection Policy
          ↓
Resolved Implementation
```

Examples:

```text
postgres
    ↓
PostgresConnector
```

```text
snowflake
    ↓
DltConnectorAdapter
```

---

## Capability-Aware Connector Resolution

Connector resolution MUST consider required capabilities when selecting among multiple compatible implementations.

Required capabilities may originate from:

- access profiles
- solution requirements
- execution plan requirements
- preflight checks

An implementation is eligible only when its declared capabilities satisfy the required capability set.

Adapter capability declarations may be static or dynamically discovered, but MUST be normalized into Relix connector capabilities before resolution completes.

---

# Connector Resolution Stickiness

Once a connector implementation is resolved for a workflow, the resolved implementation MUST remain fixed for the lifetime of the frozen execution plan.

Relix MUST NOT switch between implementations during:

- execution
- checkpoint recovery
- replay validation
- reconciliation
- retry handling

Connector implementation switching is permitted only before execution plan freeze.

---

# Initial Adapter Implementation

## DltConnectorAdapter

### Responsibilities

`DltConnectorAdapter` MAY use dlt for:

- extraction
- loading
- schema discovery
- destination connectivity
- destination abstraction
- incremental loading primitives

---

# Connector Interface Compliance

All adapters MUST implement the Relix connector interface.

Required methods include:

- `connect()`
- `disconnect()`
- `validate_connectivity()`
- `read_batch()`
- `write_batch()`
- `begin_batch()`
- `commit_batch()`
- `rollback_batch()`
- `discover_schema()`
- `get_capabilities()`

---

# Runtime Isolation

Adapters MUST NOT expose adapter-specific semantics into Relix runtime layers.

Relix runtime MUST remain backend-agnostic.

---

# Governance

Adapter-backed connectors are subject to the same:

- preflight validation
- checkpoint validation
- replay validation
- reconciliation validation

requirements as native connectors.

FR-034 governs connector availability and connector resolution only.

Connector permissions and operational access control are explicitly out of scope and addressed by future FRs.

---

# Administrative Operations

Relix SHALL support:

- adapter registration
- adapter deregistration
- adapter enablement
- adapter disablement
- supported connector registration
- supported connector disablement

The management interface is implementation-specific and may be provided through configuration, CLI, API, or UI.

UI-based connector management is outside the scope of FR-034.

Adapter deregistration MUST NOT invalidate frozen execution
plans that have already resolved the adapter.

Existing execution plans MUST continue to use their previously
resolved connector implementation until completion or retirement.

---

# Determinism Requirements

## Ordering

Relix runtime remains responsible for deterministic ordering.

Adapters MUST NOT weaken:

- deterministic pagination
- ordering guarantees
- replay consistency
- reconciliation reproducibility

These guarantees preserve the deterministic execution semantics defined by:

- FR-026 Runtime & Execution Framework
- FR-028 Checkpoint Recovery Framework
- FR-029 Reconciliation Runtime Framework

   
---

# Reconciliation

Relix reconciliation engine remains authoritative.

Adapters MAY provide helper metadata:

- counts
- checksums
- destination statistics

but reconciliation decisions MUST remain inside Relix runtime.

---

# Execution Plans

Frozen execution plans remain Relix-owned.

Adapters MUST consume execution plans but MUST NOT mutate them.

---

# Packaging

Adapter dependencies MUST remain optional.

Example:

```bash
pip install relix[dlt]
```

Core Relix installation MUST NOT require adapter-specific dependencies.

---

# Capability Mapping

Adapters MUST expose capability translation between:

- Relix connector capabilities
- Adapter destination/source capabilities

Unsupported capabilities MUST fail during preflight.

---

# Failure Semantics

Connector failures originating from adapters MUST be translated into Relix runtime errors.

Raw adapter exceptions MUST NOT propagate beyond connector boundaries.

---

# Security

Adapters MUST support Relix credential providers and MUST NOT bypass Relix secret handling mechanisms.

---

# Acceptance Criteria

FR-034 is complete when:

- Adapter framework exists
- Adapter registry exists
- Supported Connector Registry exists
- Supported connector registry enforcement works
- Connector resolution exists
- Connector resolution persistence exists
- Connector resolution remains stable across:
  - execution
  - recovery
  - replay
  - reconciliation
- Adapter-backed connector selection works
- Capability-aware connector resolution works
- Connector resolution selects only eligible implementations
- Capability translation works
- Preflight validates connector support
- Native connector fallback logic exists
- Deterministic ordering guarantees remain intact
- Reconciliation remains Relix-owned
- Optional dependency installation works
- Adapter tests validate:
  - source connectivity
  - destination connectivity
  - source-to-destination execution
  - capability translation
  - reconciliation compatibility

---

# Deferred Items

The following are deferred beyond FR-034:

- streaming connectors
- CDC semantics
- bidirectional sync
- async connector execution
- distributed connector orchestration
- connector auto-discovery marketplace
- UI-based connector management

---

# Runtime Guarantees Preserved

Adapter-backed connectors MUST NOT weaken or bypass:

- FR-028 Checkpoint Recovery Framework
- FR-029 Reconciliation Runtime Framework

---

# References

- FR-025 Connector Integration & Expansion Framework
- FR-026 Runtime & Execution Framework
- FR-032 Application Ports & Adapter Architecture
- FR-033 Preflight Workflow Framework

