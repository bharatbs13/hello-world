# FR-036 — Connector Access Profile Binding

## Phase

v0.2.1

## Objective

Define the binding mechanism that assigns access profiles to connector instances, validates those assignments during preflight, enforces profile-based permissions at runtime, and manages binding lifecycle.

FR-036 is where connector identity meets operational permissions. It answers: which connector gets which profile.

It does **NOT** answer: for what purpose, in which role, or as part of which workflow. Those questions belong to future FRs.

---

## Scope

FR-036 introduces:

- Connector-to-profile binding registry
- Binding validation
- Preflight permission validation
- Runtime permission enforcement
- Binding versioning
- Binding immutability for frozen execution plans
- Binding enablement and disablement
- Administrative operations for binding lifecycle management

### Initial Implementation

Bindings are defined per connector instance:

```yaml
connector_bindings:
  postgres_production_binding:
    connector: postgres_production
    access_profile: read_only

  snowflake_warehouse_binding:
    connector: snowflake_warehouse
    access_profile: read_write_ddl
```

FR-036 consumes:

- Connector resolution from FR-034
- Access profiles from FR-035

It does **NOT** define new permissions, new connector implementations, or workflow roles.

---

## Non-Goals

FR-036 does **NOT** address:

- workflow role assignment (source, target, etc.)
- solution-specific semantics
- user authentication or identity management
- role-based access control (RBAC) for human users
- credential management or secret handling
- dynamic runtime permission elevation
- audit logging of permission checks

FR-036 binds profiles to connectors and enforces those bindings. It does not define what any future solution does with the binding.

---

## Architectural Position

FR-036 is the binding layer between connector resolution and access control.

```text
FR-034 — Universal Connector Adapter Framework
                ↓
FR-035 — Standard Access Profile Framework
                ↓
FR-036 — Connector Access Profile Binding  ← YOU ARE HERE
                ↓
              Future FRs
```

```text
                ┌────────────────────┐
                │ Relix Runtime Core │
                └─────────┬──────────┘
                          │
        ┌─────────────────┴─────────────────┐
        │                                   │
┌──────────────────┐             ┌────────────────────┐
│ FR-034           │             │ FR-035             │
│ Connector        │             │ Access Profile     │
│ Resolution       │             │ Registry           │
└────────┬─────────┘             └─────────┬──────────┘
         │                                 │
         └──────────────┬──────────────────┘
                        ↓
              ┌────────────────────┐
              │ FR-036             │
              │ Profile Binding    │
              │ & Enforcement      │
              └────────────────────┘
```

---

## Connector-to-Profile Binding

### Binding Definition

A binding associates a connector instance with an access profile.

#### Required Fields

- `connector`: logical connector name (resolved by FR-034)
- `access_profile`: profile name (defined by FR-035)

#### Example

```yaml
connector_bindings:
  postgres_read_binding:
    connector: postgres_production
    access_profile: read_only

  snowflake_write_binding:
    connector: snowflake_warehouse
    access_profile: read_write_ddl
```

### Binding Registry

Relix maintains a registry of connector-to-profile bindings.

Each binding is uniquely identified by a binding name.

A single connector instance may have multiple bindings, each with a different profile.

#### Example

```text
postgres_read_binding  → postgres_production, read_only
postgres_admin_binding → postgres_production, admin
```

Future FRs may reference bindings.
FR-036 does not define how bindings are interpreted.

---

## Preflight Permission Validation

Preflight validation combines FR-034 connector resolution, FR-035 profile capability mapping, and FR-036 binding.

### Validation Flow

```text
Connector Binding
      ↓
Resolve Connector (FR-034)
      ↓
Resolve Profile (FR-035)
      ↓
Validate Profile ↔ Connector Capabilities (FR-035)
      ↓
Pass / Fail
```

### Example — PASS

```text
Binding: postgres_read_binding
  → postgres_production, read_only

  Resolve: PostgresConnector

  Profile:
    read_only → read, discover_schema

  Capability check:
    PostgresConnector supports
    read, discover_schema ✓

  Result: PASS
```

### Example — FAIL

```text
Binding: s3_admin_binding
  → s3_bucket, read_write_ddl

  Resolve: S3Connector

  Profile:
    read_write_ddl →
    read, write, create_table,
    alter_table, drop_table,
    truncate, discover_schema

  Capability check:
    S3Connector supports
    read, write, discover_schema

    Missing:
      create_table
      alter_table
      drop_table
      truncate

  Result: FAIL
```

Preflight failure **MUST** produce explicit, actionable error messages and **MUST** prevent execution plan freeze.

---

## Runtime Permission Enforcement

Once an execution plan is frozen and a binding is resolved, Relix **MUST** enforce the bound profile's permissions at runtime.

### Enforcement Rules

- Operations not permitted by the bound profile **MUST** be rejected before reaching the connector
- Permission violations **MUST** produce explicit errors
- Enforcement **MUST** be consistent across:
  - initial execution
  - checkpoint recovery
  - replay validation
  - reconciliation

Enforcement is permission-based.

Operation-to-permission mapping is determined by the connector interface contract and is not enumerated by FR-036.

### Example Runtime Error

```text
ERROR: Connector "postgres_production" is bound to profile "read_only".
Requested operation requires permission "write" which is not granted
by the active binding "postgres_read_binding".
```

---

## Binding Lifecycle Management

### Enablement and Disablement

Bindings support enablement and disablement.

A disabled binding:

- **MUST NOT** be available for new execution plans
- **MUST** continue to be honored by frozen execution plans that already reference it

Disabling a binding **MUST NOT** invalidate any frozen execution plan.

This matches the disablement semantics established in FR-034 (adapters) and FR-035 (profiles).

### Binding Versioning

Binding definitions are versioned.

When a binding is updated:

- A new version is created
- Existing frozen execution plans continue to reference the version resolved during their preflight
- New execution plans resolve against the current version

Binding versioning enables evolution without breaking existing plans.

This is consistent with the versioning model established in FR-035.

Binding definition updates **SHALL** be implemented by creating a new binding version.

Existing binding versions **MUST** remain immutable.

---

## Binding Immutability for Frozen Execution Plans

Once an execution plan is frozen, the resolved binding version **MUST** remain immutable for the lifetime of that plan.

Relix **MUST NOT** permit:

- modification of a binding version referenced by a frozen execution plan
- deletion of a binding version referenced by a frozen execution plan

Binding modifications that affect frozen execution plans **MUST** be rejected.

New versions of a binding **MAY** be created without affecting existing plans.

Disablement of a binding is permitted and **MUST NOT** affect frozen execution plans.

This is consistent with the stickiness guarantees established in FR-034 and FR-035.

---

## Interaction with Profile Disablement

If a profile is disabled (per FR-035 lifecycle management):

- Existing bindings that reference the disabled profile **MUST** continue to function for frozen execution plans
- The disabled profile **MUST NOT** be assignable to new bindings or new binding versions

Disablement of a profile **MUST NOT** cascade to invalidate existing bindings or their associated frozen execution plans.

---

## Administrative Operations

Relix **SHALL** support:

- binding registration
- binding retrieval
- binding listing
- binding preflight compatibility check
- binding enablement
- binding disablement
- binding version creation
- binding version deletion
- binding deletion

The management interface is implementation-specific and may be provided through configuration, CLI, API, or UI.

UI-based binding management is outside the scope of FR-036.

Binding deletion **MUST** be rejected if any version of the binding is referenced by a frozen execution plan.

Binding version deletion **MUST** be rejected if the version is referenced by a frozen execution plan.

Binding disablement is always permitted and **MUST NOT** affect:

- any frozen execution plan
- any in-progress execution
- checkpoint recovery
- replay validation
- reconciliation

---

## Determinism Requirements

### Binding Resolution Stability

Connector-to-profile bindings **MUST** be stable for the lifetime of any execution plan that references them.

Binding resolution occurs once during preflight.

Resolved permissions **MUST NOT** change during:

- execution
- checkpoint recovery
- replay validation
- reconciliation

This preserves the deterministic execution semantics defined by:

- FR-026 Runtime & Execution Framework
- FR-028 Checkpoint Recovery Framework
- FR-029 Reconciliation Runtime Framework

---

## Integration with FR-034 and FR-035

FR-036 depends on:

- FR-034: Connector resolution provides the connector implementation
- FR-035: Access profile registry provides the permission template

FR-036 does **NOT** duplicate:

- Connector capability declarations (FR-034)
- Permission taxonomy (FR-035)
- Profile capability mapping (FR-035)

FR-036 adds:

- Named binding between connector instance and profile
- Preflight binding validation
- Runtime permission enforcement
- Binding lifecycle management with versioning

---

## Extensibility

Future FRs consume FR-036 bindings by name without modifying the binding framework.

### Example

```yaml
connector_bindings:
  binding_a:
    connector: postgres_production
    access_profile: read_only

  binding_b:
    connector: snowflake_warehouse
    access_profile: read_write_ddl
```

Future FRs may reference bindings. 

FR-036 does not define how bindings are interpreted.

The binding framework remains solution-agnostic.

---

## Failure Semantics

Binding validation failures **MUST** produce explicit, actionable error messages.

### Examples

```text
ERROR: Binding "s3_admin_binding" assigns profile
"read_write_ddl" to connector "s3_bucket".

Profile requires "create_table" but connector
does not support this capability.
```

```text
ERROR: Cannot delete binding "postgres_read_binding".

Version 3 is referenced by frozen execution plan
"plan_20260611_001".

Disable the binding instead.
```

```text
ERROR: Cannot delete version 3 of binding
"postgres_read_binding".

Version is referenced by frozen execution plan
"plan_20260611_001".

Create a new version or disable the binding instead.
```

```text
ERROR: Runtime operation rejected.

Connector "postgres_production" is bound via
"postgres_read_binding" to profile "read_only".

Required permission "write" is not granted.
```

---

## Security

Bindings do **NOT** contain credentials, secrets, or authentication material.

Bindings reference connectors and profiles by name.

The underlying credential management remains governed by the existing Relix secret handling mechanisms.

Permission enforcement at runtime prevents unauthorized operations regardless of connector capabilities.

---

## Acceptance Criteria

FR-036 is complete when:

- Connector-to-profile binding registry exists
- Binding registration works
- Binding retrieval works
- Binding listing works
- Binding enablement works
- Binding disablement works
- Binding definition updates create new binding versions
- Binding deletion is rejected when any version is in use
- Binding version deletion is rejected when version is in use
- Preflight validation checks profile-to-connector compatibility
- Preflight validation failures block execution plan freeze
- Runtime enforcement rejects operations not permitted by bound profile
- Runtime enforcement is consistent across connector interface operations
- Binding versions are immutable once referenced by frozen execution plans
- Profile disablement does not invalidate existing bindings for frozen plans
- Existing bindings continue to function when referenced profiles are disabled
- Binding resolution is stable across:
  - execution
  - recovery
  - replay
  - reconciliation
- Failure messages are explicit and actionable for:
  - preflight validation failures
  - runtime permission violations
  - deletion rejections
  - version modification rejections
- Framework contains no workflow role concepts
- Framework contains no solution-specific semantics
- Framework contains no source/target concepts
- Multiple bindings per connector are supported

---

## Deferred Items

The following are deferred beyond FR-036:

- workflow role assignment (source, target, etc.) — future FRs
- solution-specific semantics — future FRs
- role-based access control for human users (future FR)
- user authentication and identity (future FR)
- dynamic runtime permission elevation
- per-operation audit logging
- UI-based binding management
- workflow-level validation of binding combinations

---

## Runtime Guarantees Preserved

Connector access profile bindings **MUST NOT** weaken or bypass:

- FR-028 Checkpoint Recovery Framework
- FR-029 Reconciliation Runtime Framework

Binding resolution stability and runtime enforcement consistency directly support deterministic replay and recovery.

---

## References

- FR-026 Runtime & Execution Framework
- FR-028 Checkpoint Recovery Framework
- FR-029 Reconciliation Runtime Framework
- FR-034 Universal Connector Adapter Framework
- FR-035 Standard Access Profile Framework
