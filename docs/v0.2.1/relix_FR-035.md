# FR-035 — Standard Access Profile Framework

## Phase

v0.2.1

## Objective

Define a standardized, solution-independent framework for access profile definition, validation, lifecycle management, and capability mapping that describes the permissible operations Relix may execute against any connector, regardless of whether the connector is native or adapter-backed.

FR-035 establishes what operations exist as permission templates and how profiles are managed throughout their lifecycle. It does **NOT** assign profiles to specific connectors, workflows, or solution roles.

---

## Scope

FR-035 introduces:

- Access Profile Registry
- Standard access profile definitions
- Permission taxonomy
- Profile validation
- Profile capability mapping against connector declarations
- Access profile lifecycle management
- Access profile enablement and disablement
- Profile versioning
- Profile immutability guarantees for frozen execution plans
- Administrative operations for profile lifecycle management

### Initial Implementation

#### Standard Profiles

| Profile | Permissions |
|----------|-------------|
| read_only | read, discover_schema |
| read_metadata | read, discover_schema, get_statistics |
| read_write | read, write, discover_schema |
| read_write_ddl | read, write, create_table, alter_table, drop_table, truncate, discover_schema |
| admin | * |

All profiles are solution-independent, generic platform constructs.

No profile implies or depends on migration, replication, CDC, DR, or any future solution semantics.

FR-036 binds profiles to connectors.

Future solution FRs bind profiles to workflow roles.

FR-035 does **NOT** replace or override connector-level capability declarations.

A connector's declared capabilities remain authoritative. An access profile that requests a capability the connector does not support **MUST** fail preflight validation.

---

## Non-Goals

FR-035 does **NOT** address:

- which connector receives which profile (deferred to FR-036)
- which workflow role receives which profile (deferred to solution FRs)
- source vs target role validation (deferred to solution FRs)
- user authentication or identity management
- role-based access control (RBAC)
- credential management or secret handling
- runtime enforcement of profile bindings (deferred to FR-036)
- per-workflow permission overrides
- solution-specific permissions or profiles

FR-035 defines the permission vocabulary, profile lifecycle, and validation against connector capabilities only.

---

## Architectural Position

FR-035 sits between the Universal Connector Adapter Framework (FR-034) and Connector Access Profile Binding (FR-036).

```text
FR-025 — Connector Integration & Expansion Framework
                ↓
FR-034 — Universal Connector Adapter Framework
                ↓
FR-035 — Standard Access Profile Framework  ← YOU ARE HERE
                ↓
FR-036 — Connector Access Profile Binding
                ↓
        Future Solution FRs
    (Migration, Replication, CDC, DR)
```

```text
                ┌────────────────────┐
                │ Relix Runtime Core │
                └─────────┬──────────┘
                          │
                ┌─────────┴──────────┐
                │ Access Profile     │
                │ Registry           │
                └─────────┬──────────┘
                          │
        ┌─────────────────┴─────────────────┐
        │                                   │
┌──────────────────┐             ┌────────────────────┐
│ Connector        │             │ Profile            │
│ Capability       │             │ Capability         │
│ Declaration      │             │ Mapping            │
└──────────────────┘             └────────────────────┘
```

---

## Permission Taxonomy

### Standard Permissions (v0.2.1)

| Permission | Scope | Description |
|------------|--------|-------------|
| read | Data | Read rows from connector |
| write | Data | Insert rows into connector |
| upsert | Data | Insert or update rows atomically |
| delete | Data | Delete rows from connector |
| truncate | Data | Truncate table or dataset |
| discover_schema | Metadata | Discover table schemas, columns, types |
| get_statistics | Metadata | Retrieve row counts, size estimates |
| create_table | DDL | Create new tables or datasets |
| alter_table | DDL | Modify existing table schemas |
| drop_table | DDL | Drop tables or datasets |

### Wildcard Permission

The `*` wildcard grants all permissions defined in the v0.2.1 taxonomy.

The `admin` profile includes all permissions.

### Deferred Permissions

The following permissions are explicitly deferred beyond v0.2.1:

- read_change_log
- create_index
- create_publication
- execute_procedure
- manage_credentials

These will be introduced in future FRs when the corresponding runtime capabilities and security model exist.

Future FRs may extend the permission taxonomy and subsequently register profiles using those permissions without requiring structural changes to FR-035.

---

## Access Profile Registry

Relix maintains a registry of defined access profiles.

### Example

```yaml
access_profiles:
  read_only:
    description: "Read-only access for inspection and extraction"
    permissions:
      - read
      - discover_schema
    enabled: true

  read_metadata:
    description: "Read access with metadata inspection"
    permissions:
      - read
      - discover_schema
      - get_statistics
    enabled: true

  read_write:
    description: "Read and write access"
    permissions:
      - read
      - write
      - discover_schema
    enabled: true

  read_write_ddl:
    description: "Read, write, and full DDL access"
    permissions:
      - read
      - write
      - create_table
      - alter_table
      - drop_table
      - truncate
      - discover_schema
    enabled: true

  admin:
    description: "Full access"
    permissions:
      - "*"
    enabled: true
```

All profiles are generic platform constructs.

Profile assignment is outside the scope of FR-035.

Connector-to-profile binding is defined by FR-036.

Workflow-role-to-profile binding is defined by future FRs.

---

## Configuration

### Profile Definition

Profiles may be defined through configuration, CLI, API, or UI.

#### Example

```yaml
access_profiles:
  custom_reader:
    description: "Custom read-only profile with statistics"
    permissions:
      - read
      - discover_schema
      - get_statistics
    enabled: true
```

### Profile Validation

Each profile **MUST** be validated at definition time.

Validation checks:

- All permissions are recognized by the v0.2.1 permission taxonomy
- No conflicting or mutually exclusive permissions exist
- Profile name is unique within the registry

Invalid profiles **MUST** be rejected at registration time.

---

## Profile Capability Mapping

Access profiles are validated against connector capabilities during preflight.

This is the final and only compatibility validation performed by FR-035.

### Mapping Flow

```text
Access Profile
      ↓
Required Permissions
      ↓
Connector Capability Declaration
      ↓
Compatibility Assessment
      ↓
Pass / Fail
```

### Example — PASS

```text
Profile: read_write_ddl
  Required: read, write, create_table, alter_table, drop_table,
            truncate, discover_schema

  Connector: PostgresConnector

  Capabilities:
    read
    write
    create_table
    alter_table
    drop_table
    truncate
    discover_schema

  Result: PASS
```

### Example — FAIL

```text
Profile: read_write_ddl
  Required: read, write, create_table, alter_table,
            drop_table, truncate, discover_schema

  Connector: S3Connector

  Capabilities:
    read
    write
    discover_schema

  Result: FAIL
    (create_table, alter_table,
     drop_table, truncate not supported)
```

Unsupported capability requests **MUST** cause preflight failure with explicit messaging.

FR-035 stops at connector capability compatibility.

It does not validate whether a profile is appropriate for a source vs target role.

That validation belongs to FR-036 or future solution FRs.

---

## Profile Lifecycle Management

### Enablement and Disablement

Access profiles support enablement and disablement.

A disabled profile:

- MUST NOT be available for new connector bindings
- MUST NOT be assignable to new execution plans
- MUST continue to be honored by frozen execution plans that already reference it

Disabling a profile **MUST NOT** invalidate any frozen execution plan.

```text
Plan A
  uses read_write

Admin disables read_write

Plan A recovery MUST succeed
```

This matches the adapter disablement semantics established in FR-034 and preserves the replay and recovery guarantees of FR-028 and FR-029.

Profile deletion remains blocked if any frozen execution plan references the profile.

Disablement is the mechanism for preventing future use while honoring existing commitments.

### Profile Versioning

Profile definitions **MAY** be versioned.

When a profile is updated:

- A new version is created
- Existing frozen execution plans continue to reference the version resolved during their preflight
- New execution plans resolve against the current version

Profile versioning enables evolution without breaking existing plans.

---

## Immutability for Frozen Execution Plans

Once an access profile is bound to a connector and the execution plan is frozen, the resolved profile version **MUST** remain immutable for the lifetime of that frozen execution plan.

Relix **MUST NOT** permit:

- modification of a profile version that is referenced by a frozen execution plan
- deletion of a profile that is referenced by a frozen execution plan
- permission downgrade that would invalidate a frozen plan's operations

Profile modifications that affect frozen execution plans **MUST** be rejected.

New versions of a profile **MAY** be created without affecting existing plans.

Disablement of a profile is permitted and **MUST NOT** affect frozen execution plans.

This is consistent with the stickiness guarantees established in FR-034.

---

## Administrative Operations

Relix **SHALL** support:

- profile registration
- profile retrieval
- profile listing
- profile capability compatibility check
- profile enablement
- profile disablement
- profile version creation
- profile deletion

Profile definition updates SHALL be implemented through profile version creation.

Existing profile versions MUST remain immutable.

The management interface is implementation-specific and may be provided through configuration, CLI, API, or UI.

UI-based profile management is outside the scope of FR-035.

Profile deletion **MUST** be rejected if the profile is referenced by:

- any frozen execution plan
- any active connector binding (FR-036)

Profile disablement is always permitted and **MUST NOT** affect:

- any frozen execution plan
- any in-progress execution
- checkpoint recovery
- replay validation
- reconciliation

---

## Determinism Requirements

### Profile Resolution Stability

Profile definitions **MUST** be stable for the lifetime of any execution plan that references them.

Profile resolution occurs once during preflight.

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

## Integration with FR-034

Access profiles are connector-implementation-agnostic.

The same profile applies to:

- Native connectors (`PostgresConnector`, `MySQLConnector`)
- Adapter-backed connectors (`DltConnectorAdapter`)

FR-034 connector resolution resolves which connector implementation.

FR-035 defines what operations are permitted against that implementation.

Connector-to-profile binding is defined by FR-036.

---

## Extensibility

Future FRs **MAY** register additional profiles through the standard profile registration mechanism without modifying FR-035.

### Example of a Future Profile Registration

```yaml
access_profiles:
  custom_profile:
    description: "Future profile"
    permissions:
      - read
      - discover_schema
      - some_future_permission
    enabled: true
```

This registration uses the same registry, validation, and lifecycle management defined by FR-035.

No framework change is required.

---

## Failure Semantics

Profile validation failures **MUST** produce explicit, actionable error messages.

### Examples

```text
ERROR: Profile "read_write_ddl" requires "create_table"
but connector "s3_source" does not support this capability.
```

```text
ERROR: Permission "some_future_permission"
is not recognized in the v0.2.1 permission taxonomy.
```

```text
ERROR: Cannot delete profile "read_only".
Profile is referenced by 3 frozen execution plans.
Disable the profile instead.
```

---

## Security

Access profile definitions do **NOT** contain credentials, secrets, or authentication material.

Profiles define operational boundaries only.

Credential management remains governed by the existing Relix secret handling mechanisms.

---

## Acceptance Criteria

FR-035 is complete when:

- Access Profile Registry exists
- Standard profiles are defined and registered (`read_only`, `read_metadata`, `read_write`, `read_write_ddl`, `admin`)
- Permission taxonomy is documented and enforced
- Custom profile registration works
- Profile validation rejects unknown permissions
- Profile validation rejects conflicting permissions
- Profile capability mapping works against connector declarations
- Profile enablement and disablement works
- Disabling a profile does not affect frozen execution plans
- Profile definition updates create new profile versions
- Multiple profile versions may coexist
- Frozen execution plans retain their resolved profile version
- Profile immutability is enforced for frozen execution plans
- Profile deletion is rejected when profiles are in use
- Profile deletion error message suggests disablement as alternative
- Profile updates are rejected when profile versions are in use
- Profile retrieval works
- Profile listing works
- Profile resolution is stable across:
  - execution
  - recovery
  - replay
  - reconciliation
- Failure messages are explicit and actionable
- Profiles are connector-implementation-agnostic
- Profiles contain no solution-specific semantics
- No profile name implies migration, replication, CDC, DR, or any future solution context
- The standard v0.2.1 profiles are:
  - read_only
  - read_metadata
  - read_write
  - read_write_ddl
  - admin

---

## Deferred Items

The following are deferred beyond FR-035:

- connector-to-profile binding (FR-036)
- workflow-role-to-profile binding (solution FRs)
- source vs target role validation (solution FRs)
- per-operation runtime enforcement (FR-036)
- role-based access control (future FR)
- user authentication and identity (future FR)
- dynamic permission elevation requests
- audit logging of permission usage
- UI-based profile management
- permissions:
  - read_change_log
  - create_index
  - create_publication
  - execute_procedure
  - manage_credentials
- solution-specific profiles of any kind

---

## Runtime Guarantees Preserved

Access profiles **MUST NOT** weaken or bypass:

- FR-028 Checkpoint Recovery Framework
- FR-029 Reconciliation Runtime Framework

Profile resolution stability and disablement-safe semantics directly support deterministic replay and recovery.

---

## References

- FR-026 Runtime & Execution Framework
- FR-028 Checkpoint Recovery Framework
- FR-029 Reconciliation Runtime Framework
- FR-034 Universal Connector Adapter Framework

Connector-to-profile binding is defined by FR-036.
