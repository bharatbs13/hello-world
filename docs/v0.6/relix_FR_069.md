# FR-068 — Governed Agent Capability Discovery

## Target Version
v0.6

## Scope

Defines how agents discover only governed and configured Relix capabilities rather than raw connector capabilities.

This FR establishes controlled discovery boundaries between:

- intelligent agents
- MCP clients
- connector registries
- governed execution systems

Covers:

- governed capability exposure
- source/destination discovery
- policy-aware connector visibility
- capability metadata exposure
- connector registration visibility
- agent-safe discovery APIs
- restricted connector enumeration

Principle:

```text
Agents see governed capabilities, not theoretical connector capabilities.