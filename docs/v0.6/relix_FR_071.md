# FR-071 — Least-Privilege Connector Governance

## Target Version
v0.6

## Scope

Defines minimum-access governance rules for database connectors and agent execution systems.

This FR ensures agents operate only within explicitly approved boundaries.

Covers:

- read-only enforcement
- schema/table restrictions
- row limits
- query timeout policies
- optional column masking
- operation-scoped permissions
- governed write approval
- connector-level restriction policies

Does NOT yet cover:

- adaptive privilege escalation
- dynamic trust scoring
- cross-tenant governance orchestration
- behavioral access adaptation