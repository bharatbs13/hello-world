# Relix FR-035 — Observability Signal Scope & Identity Contract

## Target Version

v0.3 Core Telemetry Foundation

---

## Scope

Platform / Observability / Schema

---

## Objective

Define a common identity, scope, hierarchy, lineage, tenancy, storage, timestamp lifecycle, ingestion lifecycle, and telemetry-plane contract for telemetry records, report records, and alert records.

---

## Architecture

```text
Platform Event Source
        ↓
Observability Identity Contract
        ↓
Telemetry / Reports / Alerts
        ↓
Consumers
```

Consumers:

- reporting framework
- alerting framework
- replay diagnostics
- distributed workers
- dashboards
- analytics
- agent explanations

---

## Common Metadata Attributes

Required:

- `record_id`
- `record_type`
- `record_schema_version`
- `scope_type`
- `scope_id`
- `parent_scope_type`
- `parent_scope_id`
- `scope_version`
- `tenant_id`
- `observed_at`
- `ingested_at`
- `created_at`
- `source_service`
- `record_source_type`
- `metadata`

Optional:

- `workspace_id`
- `environment_id`
- `solution_type`
- `timestamp_origin`
- `telemetry_plane`
- `ingestion_state`

Supported `timestamp_origin`:

- `live`
- `reconstructed`
- `imported`
- `replayed`

---

## Telemetry Plane Rules

Telemetry records must define:

- `telemetry_plane`

Supported values:

- `control_plane`
- `data_plane`
- `error_plane`

Report and alert records may inherit plane ownership from source telemetry.

---

## Timestamp Definitions

`observed_at`

→ when event occurred

`ingested_at`

→ when collector received event

`created_at`

→ when record persisted/generated

---

## Timestamp Ordering Rules

If timestamps exist:

```text
observed_at <= ingested_at <= created_at
```

Exceptions:

- historical imports
- replay reconstruction

Such records must specify:

```text
timestamp_origin=reconstructed
```

---

## Clock Synchronization Rules

Timestamp ordering assumes synchronized clocks.

Systems may support:

- `clock_skew_tolerance`

Example:

```text
clock_skew_tolerance=5s
```

Values outside tolerance may emit:

- `OBSERVABILITY_CLOCK_SKEW_DETECTED`

---

## Ingestion State Rules

Supported values:

- `received`
- `validated`
- `persisted`
- `archived`
- `rejected`

---

## Ingestion State Transition Rules

Allowed:

```text
received
    ↓
validated
    ↓
persisted
    ↓
archived

received
    ↓
rejected

validated
    ↓
rejected
```

Prohibited:

```text
archived
    ↓
persisted

rejected
    ↓
persisted
```

Examples:

Connector metric:

```text
observed_at=10:00:01
ingested_at=10:00:04
created_at=10:00:07
ingestion_state=persisted
```

Rejected records may emit:

- `OBSERVABILITY_RECORD_REJECTED`

Rejected records must not mutate:

- workflow state
- execution plans
- checkpoint state
- reconciliation state

---

## Trace Attributes

- `trace_id`
- `span_id`
- `parent_span_id`
- `correlation_id`
- `causation_id`
- `parent_record_id`

---

## Trace Rules

`trace_id`

must be globally unique

`span_id`

must be unique within `trace_id`

If `span_id` exists:

- `trace_id` must exist

---

## Storage & Query Requirements

Required:

- persist observability records
- query by `record_id`
- query by `scope_type + scope_id`
- query by `correlation_id`
- query by `trace_id`
- query by `telemetry_plane`
- query by `observed_at`
- query by `ingested_at`
- query by `created_at`
- support append-only writes
- support retention
- support archival

---

## Retention Resolution Rules

Priority:

```text
record-level
    ↓
tenant-level
    ↓
platform default
```

---

## Recommended Indexes

- (`record_id`)
- (`scope_type`, `scope_id`, `created_at`)
- (`correlation_id`)
- (`trace_id`)
- (`telemetry_plane`, `created_at`)
- (`observed_at`)
- (`ingested_at`)
- (`tenant_id`, `created_at`)

---

## Boundary Rules

`record_source_type`

→ who emitted record

`telemetry_plane`

→ runtime-plane ownership

These fields must not be interchangeable.

---

## Acceptance Criteria

1. Common identity model exists.

2. Timestamp lifecycle is defined.

3. Timestamp ordering rules exist.

4. Clock skew rules exist.

5. Ingestion lifecycle exists.

6. Trace uniqueness rules exist.

7. Telemetry-plane rules exist.

8. Storage/query requirements exist.

9. Runtime behavior remains unaffected.

---

## Architectural Rationale

Using:

```text
scope_type + scope_id + telemetry_plane
```

creates a reusable identity model across:

- telemetry
- reporting
- alerting
- distributed execution
- replay diagnostics
- analytics
- agent explanations

while preserving deterministic execution behavior.
