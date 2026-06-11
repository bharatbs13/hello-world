FR-034 — Universal Connector Adapter Framework

Phase

v0.2.1

Objective

Provide a universal connector adapter framework that allows Relix to integrate third-party connector ecosystems while preserving Relix deterministic runtime semantics.

The initial adapter implementation for FR-034 is DltConnectorAdapter.

⸻

Scope

FR-034 introduces:

* Universal connector adapter framework
* Connector selection policy
* Adapter registry
* Supported Connector Registry
* Native-preferred fallback semantics
* Capability mapping between Relix and adapter ecosystems
* Runtime-safe adapter isolation
* Optional dependency packaging

Initial implementation:

* DltConnectorAdapter

FR-034 does NOT replace native Relix connectors.

Native connectors remain first-class connector implementations within Relix.

⸻

Non-Goals

FR-034 does NOT delegate the following responsibilities to third-party adapters:

* deterministic execution orchestration
* execution checkpoints
* reconciliation semantics
* event lifecycle management
* execution plan freezing
* runtime ordering guarantees
* append-only event semantics
* Relix protocol semantics

Relix remains authoritative for all runtime semantics.

⸻

Architectural Position

FR-034 extends the connector framework established by FR-025.

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

Future adapter implementations (Airbyte, custom SDK, etc.) may be added in later releases.

⸻

Connector Selection Policy

Default Policy

Relix MUST prefer native connectors when available.

Selection order:

1. Native connector
2. Compatible adapter connector
3. Fail if no compatible connector exists

⸻

Configuration

Example:

connector_policy:
  mode: native_preferred
  allow_adapter_connectors: true

Supported Modes

Mode	Meaning
native_only	only native connectors allowed
adapter_only	only adapter-backed connectors allowed
native_preferred	native first, adapter fallback
adapter_preferred	adapter first, native fallback

⸻

Adapter Registry

Relix maintains a registry of supported adapter implementations.

Example:

adapter_registry:
  - dlt

Future implementations may include additional adapters.

⸻

Supported Connector Registry

The Supported Connector Registry applies to both native connectors and adapter-backed connectors.

Adapter-backed connectors do not automatically become supported Relix connectors.

Relix explicitly controls which connectors are exposed as supported connectors.

Example:

supported_connectors:
  postgres:
    enabled: true
  mysql:
    enabled: true
  snowflake:
    enabled: true

Adapter capability does not imply Relix support.

A connector is considered supported only when:

* the adapter supports it (if adapter-backed)
* Relix enables it
* preflight validation succeeds

⸻

Initial Adapter Implementation

DltConnectorAdapter

Responsibilities

DltConnectorAdapter MAY use dlt for:

* extraction
* loading
* schema discovery
* destination connectivity
* destination abstraction
* incremental loading primitives

⸻

Connector Interface Compliance

All adapters MUST implement the Relix connector interface.

Required methods include:

* connect()
* disconnect()
* validate_connectivity()
* read_batch()
* write_batch()
* begin_batch()
* commit_batch()
* rollback_batch()
* discover_schema()
* get_capabilities()

⸻

Runtime Isolation

Adapters MUST NOT expose adapter-specific semantics into Relix runtime layers.

Relix runtime MUST remain backend-agnostic.

⸻

Governance

Adapter-backed connectors are subject to the same:

* preflight validation
* checkpoint validation
* replay validation
* reconciliation validation

requirements as native connectors.

FR-034 governs connector availability only.

Connector permissions and operational access control are explicitly out of scope and addressed by future FRs.

⸻

Determinism Requirements

Ordering

Relix runtime remains responsible for deterministic ordering.

Adapters MUST NOT weaken:

* deterministic pagination
* ordering guarantees
* replay consistency
* reconciliation reproducibility

⸻

Reconciliation

Relix reconciliation engine remains authoritative.

Adapters MAY provide helper metadata:

* counts
* checksums
* destination statistics

but reconciliation decisions MUST remain inside Relix runtime.

⸻

Execution Plans

Frozen execution plans remain Relix-owned.

Adapters MUST consume execution plans but MUST NOT mutate them.

⸻

Packaging

Adapter dependencies MUST remain optional.

Example:

pip install relix[dlt]

Core Relix installation MUST NOT require adapter-specific dependencies.

⸻

Capability Mapping

Adapters MUST expose capability translation between:

* Relix connector capabilities
* Adapter destination/source capabilities

Unsupported capabilities MUST fail during preflight.

⸻

Failure Semantics

Connector failures originating from adapters MUST be translated into Relix runtime errors.

Raw adapter exceptions MUST NOT propagate beyond connector boundaries.

⸻

Security

Adapters MUST support Relix credential providers and MUST NOT bypass Relix secret handling mechanisms.

⸻

Acceptance Criteria

FR-034 is complete when:

* Adapter framework exists
* Adapter registry exists
* Supported Connector Registry exists
* Supported connector registry enforcement works
* Adapter-backed connector selection works
* Capability translation works
* Preflight validates connector support
* Native connector fallback logic exists
* Deterministic ordering guarantees remain intact
* Reconciliation remains Relix-owned
* Optional dependency installation works
* Adapter tests validate:
    * source connectivity
    * destination connectivity
    * source-to-destination execution
    * capability translation
    * reconciliation compatibility

⸻

Deferred Items

The following are deferred beyond FR-034:

* streaming connectors
* CDC semantics
* bidirectional sync
* async connector execution
* distributed connector orchestration
* connector auto-discovery marketplace

⸻

Runtime Guarantees Preserved

Adapter-backed connectors must not weaken or bypass:

* FR-028 Checkpoint Recovery Framework
* FR-029 Reconciliation Runtime Framework

⸻

References

* FR-025 Connector Integration & Expansion Framework
* FR-026 Runtime & Execution Framework
* FR-032 Application Ports & Adapter Architecture
* FR-033 Preflight Workflow Framework