
# FR-xxx — Connector Access Control Framework

## Phase

v0.2.1

## Objective

Provide a centralized access-control and governance framework for all Relix connectors.

The framework defines how Relix controls connector permissions, source/destination roles, operation authorization, and runtime enforcement independently of the underlying connector technology.

---

## Scope

FR-064 introduces:

* connector access policies
* source/destination role governance
* operation authorization
* access-mode enforcement
* runtime operation guards
* preflight access validation
* audit logging

This framework applies to:

* Native Connectors
* DltConnectorAdapter
* Future Connector Adapters
* File Connectors
* API Connectors
* SaaS Connectors

---

## Core Principle

```text
Governance applies to connector role,
not connector technology.
```

Relix MUST enforce access policies regardless of:

* database permissions
* cloud permissions
* connector capabilities
* user privileges

---

## Connector Roles

Every connector MUST be assigned a role.

### Allowed Roles

```yaml
role: source
```

```yaml
role: destination
```

---

## Access Modes

Every connector MUST declare an access mode.

### Example

```yaml
sources:
  - id: sales_pg
    type: postgres
    role: source
    access_mode: read_only

destinations:
  - id: warehouse_pg
    type: postgres
    role: destination
    access_mode: write_allowed
```

---

## Supported Access Modes

### Read Only

```yaml
access_mode: read_only
```

Allowed:

```text
SELECT
READ
SCAN
EXPORT
METADATA DISCOVERY
```

Forbidden:

```text
INSERT
UPDATE
DELETE
TRUNCATE
ALTER
DROP
CREATE
MERGE
UPSERT
```

---

### Write Allowed

```yaml
access_mode: write_allowed
```

Allowed operations depend on connector implementation and deployment policy.

---

## Source Protection Rule

Relix MUST treat source connectors as read-only resources.

### Mandatory Rule

```text
Source connectors are read-only by Relix policy,
regardless of underlying privileges.
```

Example:

```text
DB user has:
  INSERT
  UPDATE
  DELETE

Relix source policy:
  READ ONLY

Result:
  mutation requests rejected
```

---

## Destination Protection Rule

Destination connectors MAY allow write operations only if:

* configured by policy
* validated during preflight
* approved by execution plan

---

## Enforcement Layers

### Layer 1 — Configuration Validation

Validate:

* role
* access_mode
* policy completeness

---

### Layer 2 — Preflight Validation

Validate:

* connector accessibility
* credential availability
* policy consistency
* operation compatibility

Execution MUST NOT begin if validation fails.

---

### Layer 3 — Runtime Operation Guard

All connector operations MUST pass through Relix authorization checks.

Example:

```text
read()
write()
execute_sql()
execute_query()
truncate()
merge()
```

Unauthorized operations MUST be rejected.

---

### Layer 4 — SQL Mutation Guard

Relix MUST detect and reject mutation operations on read-only connectors.

Examples:

```sql
INSERT
UPDATE
DELETE
MERGE
UPSERT
DROP
ALTER
TRUNCATE
CREATE
```

---

### Layer 5 — Role Separation

Relix MUST preserve logical separation between:

```text
Source Connectors
Destination Connectors
```

A source connector MUST NOT automatically acquire destination privileges.

---

## Connector Technology Independence

This framework MUST apply equally to:

| Connector Type      | Governed |
| ------------------- | -------- |
| Native Connector    | Yes      |
| DltConnectorAdapter | Yes      |
| REST API Connector  | Yes      |
| File Connector      | Yes      |
| SaaS Connector      | Yes      |
| Future Connector    | Yes      |

---

## Audit Requirements

Relix SHOULD emit audit events for:

* unauthorized reads
* unauthorized writes
* mutation attempts on source connectors
* policy violations
* access-mode mismatches
* runtime authorization failures

---

## Acceptance Criteria

FR-xxx is complete when:

* connector roles exist
* access_mode exists
* source read-only enforcement exists
* runtime operation guards exist
* preflight validates access policies
* mutation attempts are blocked on source connectors
* native connectors comply
* DltConnectorAdapter complies
* audit events are generated

---

## Governing Principle

```text
Relix is the authority for connector access control.

Connector capabilities do not grant permissions.

Permissions are granted only through Relix policy.
```

This is likely stronger and more future-proof than a "Controlled Connector Governance Framework" because it establishes a clear security boundary that every connector subsystem (v0.2.x, v0.3.x, and beyond) must obey.
