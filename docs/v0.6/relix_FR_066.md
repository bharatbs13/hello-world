# FR-066 — Credential-Safe Agent / MCP Database Access

## Target Version
v0.6

## Scope

Defines the governed security boundary for all agent-initiated and MCP-mediated database access.

This FR establishes that:

- agents never receive raw credentials
- credentials are internally resolved by Relix
- all DB access passes through governed execution layers
- access policies are enforced before execution
- database operations become auditable and controllable

Covers:

- secret non-exposure
- governed execution mediation
- internal credential resolution
- read/write restriction enforcement
- least-privilege access
- credential-safe SDK interactions
- secure connector invocation

Does NOT yet cover:

- enterprise IAM federation
- temporary token minting
- adaptive runtime security scoring
- anomaly detection
- advanced sandbox isolation