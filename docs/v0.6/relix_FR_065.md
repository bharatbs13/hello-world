# FR-065 — Intelligent Agent Connector Layer

## Status

Proposed

## Phase

`v0.6`

## Objective

Provide an intelligent agent-facing connector interaction layer for Relix that enables AI agents, orchestration systems, copilots, and autonomous workflows to safely interact with Relix-managed connectors using a stable SDK abstraction instead of raw database or `dlt` APIs.

FR-065 introduces an intelligent connector interaction layer designed for agentic systems while preserving Relix governance, determinism, reconciliation, and security guarantees.

---

## Scope

FR-065 introduces:

* agent-facing connector SDK
* intelligent connector discovery
* governed connector operations
* agent-safe table discovery
* capability-aware execution APIs
* connector introspection
* execution intent abstraction
* connector policy visibility
* agent-oriented execution templates

FR-065 builds on:

* FR-063 Universal Connector Adapter Framework
* FR-064 Controlled `dlt` Governance & Access Framework

---

## Architectural Principle

```text
Agents interact with Relix abstractions,
not raw connectors or raw dlt APIs.
```

Additional principle:

```text
Agents see configured capabilities, not theoretical connector capabilities.
```

---

## Architecture

```text
Agent / Copilot / LLM
          │
          ▼
RelixAgentConnectorSDK
          │
          ▼
RelixDltController
          │
          ▼
Connector Layer
(native or dlt-backed)
```

---

## Design Goals

The intelligent layer MUST:

* simplify agent integration
* abstract connector complexity
* prevent unsafe connector access
* expose governed execution primitives
* preserve deterministic runtime behavior
* support future multi-agent orchestration

---

## Non-Goals

FR-065 does NOT allow:

* unrestricted database access
* arbitrary SQL execution by agents
* direct `dlt` API access
* uncontrolled connector creation
* bypassing Relix governance policies

---

## Agent SDK

### Example

```python
from relix.sdk import RelixClient

client = RelixClient.from_yaml("relix.yml")

sources = client.list_sources()

tables = client.list_tables("sales_pg")

result = client.snapshot(
    source="sales_pg",
    destination="warehouse_duckdb",
    tables=["public.orders"],
)
```

Agents MUST interact only through SDK primitives.

---

## SDK Responsibilities

The SDK MUST provide:

* source discovery
* destination discovery
* table discovery
* capability inspection
* policy inspection
* governed execution APIs
* reconciliation summaries
* execution status APIs

---

## Supported SDK Operations

| Operation | Description |
|---|---|
| `list_sources()` | list configured sources |
| `list_destinations()` | list configured destinations |
| `list_tables(source_id)` | list governed tables |
| `get_capabilities()` | connector capabilities |
| `validate_access()` | permission validation |
| `snapshot()` | governed snapshot execution |
| `get_status()` | execution status |
| `get_reconciliation()` | reconciliation summary |

---

## Intelligent Capability Discovery

The intelligent layer MUST expose only Relix-governed sources, destinations, tables, policies, and capabilities already registered through FR-064.

It MUST NOT expose the full raw `dlt` connector ecosystem to agents.

The SDK SHOULD expose machine-readable capability metadata.

Example:

```json
{
  "connector_type": "postgres",
  "supports_snapshot": true,
  "supports_incremental": false,
  "supports_schema_discovery": true
}
```

---

## Connector Abstraction

Agents MUST NOT require knowledge of:

* SQLAlchemy
* `dlt`
* database-specific drivers
* vendor-specific APIs
* connector internals

The SDK MUST abstract connector implementation details.

---

## Governance Integration

All SDK operations MUST pass through:

```text
RelixDltController
```

or equivalent governance layers.

---

## Policy Visibility

The SDK MAY expose policy visibility APIs.

Example:

```python
client.get_policy("sales_pg")
```

Policies returned MUST be sanitized and MUST NOT expose secrets.

---

## Agent Safety

The SDK MUST reject:

* unregistered sources
* unregistered destinations
* unauthorized tables
* unsupported operations
* policy violations

before execution begins.

---

## Preflight Integration

FR-033 preflight MUST validate:

* connector accessibility
* policy compliance
* capability compatibility
* execution intent validity

before execution starts.

---

## Determinism Requirements

The intelligent layer MUST NOT weaken:

* deterministic execution
* checkpoint semantics
* replay consistency
* reconciliation reproducibility
* ordering guarantees

Relix runtime remains authoritative for execution semantics.

---

## Agent Templates

The SDK SHOULD support reusable execution templates.

Example:

```yaml
template: snapshot_all_orders

source: sales_pg
destination: warehouse_duckdb

tables:
  - public.orders
  - public.order_items
```

---

## Multi-Agent Compatibility

The intelligent layer SHOULD support future:

* multi-agent orchestration
* planner/executor agents
* autonomous remediation agents
* governance agents
* reconciliation agents

---

## Security

The SDK MUST:

* integrate with Relix secret providers
* prevent secret exposure
* sanitize errors returned to agents
* isolate raw connector exceptions

---

## Auditability

The intelligent layer SHOULD emit audit events for:

* agent connector selection
* unauthorized access attempts
* execution requests
* governance failures
* reconciliation failures

---

## Packaging

The intelligent layer SHOULD remain modular and optional.

Example:

```text
pip install relix[agent]
```

---

## Acceptance Criteria

FR-065 is complete when:

* `RelixAgentConnectorSDK` exists
* agents can discover governed sources/destinations
* agents can execute governed snapshots
* capability inspection APIs exist
* unauthorized access is rejected
* deterministic semantics remain intact
* reconciliation remains Relix-owned
* at least one agent workflow executes successfully

---

## Deferred Items

The following are deferred:

* natural-language planning
* autonomous SQL generation
* RL-based connector optimization
* distributed agent swarms
* semantic schema reasoning
* self-healing connector remediation
* autonomous governance negotiation

---

## References

* FR-033 Preflight Framework
* FR-063 Universal Connector Adapter Framework
* FR-064 Controlled `dlt` Governance & Access Framework

