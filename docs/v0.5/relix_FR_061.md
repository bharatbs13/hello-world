# FR-061 — Organization Groups & RBAC Framework

## Target Version

`v0.5`

## Scope

Platform / Enterprise Governance

## Status

Proposed

## Objective

Introduce organization-aware role-based access control (`RBAC`) for Relix.

The framework must support:

- Relix platform administrators
- Customer organizations
- Groups
- Roles
- Permissions
- Organization membership isolation
- Authorization policy enforcement

## Problem Statement

Authentication identifies users but does not determine allowed actions.

Relix requires:

- Multi-customer isolation
- Permission enforcement
- Organization separation
- Workflow authorization
- Enterprise governance

## Architecture

```text
Relix Platform Admin Group
        |
        v
Customer Organization
        |
        v
Organization Groups
        |
        v
Roles
        |
        v
Permissions
        |
        v
Authorized Actions
```

## Core Components

Authorization service defines:

- `Group`
- `Role`
- `Permission`
- `Membership`
- `Organization`
- `AuthorizationPolicy`

## Default Role Examples

### Platform Roles

- `RELIX_ADMIN`
- `RELIX_SUPPORT`
- `RELIX_OPERATOR`

### Customer Roles

- `ORG_ADMIN`
- `WORKFLOW_MANAGER`
- `WORKFLOW_OPERATOR`
- `VIEWER`
- `AUDITOR`

## Authorization Rules

- Permissions must be evaluated through roles.
- Roles must be assigned through groups.
- Organization boundaries must be enforced.
- Users cannot access external organization resources.
- Authorization decisions must be event-backed.

## Access Evaluation

```text
User
   |
   v
Membership
   |
   v
Group
   |
   v
Role
   |
   v
Permission
   |
   v
Allow / Deny
```

## Non-Goals

Not included:

- `SAML`
- `OAuth` providers
- External identity federation
- Policy AI generation
- Cross-organization privilege inheritance

## Acceptance Criteria

| ID | Criteria |
|----|-----------|
| `AC-1` | Platform administrator group exists |
| `AC-2` | Organization groups exist |
| `AC-3` | Role hierarchy exists |
| `AC-4` | Permission evaluation exists |
| `AC-5` | Organization isolation exists |
| `AC-6` | Authorization decisions are enforced |
| `AC-7` | Access events are persisted |