
# Document 4: Topology Discovery Agent v0.6.3

**File:** `docs/agents/topology-discovery-agent-v0.6.3.md`

---

# Topology Discovery Agent v0.6.3

**Status: FROZEN**
**Version: v0.6.3**
**Type: Agent**
**Module: `capabilities/topology`**
**Depends on: `agentic-runtime-foundation-v0.6.0.md`**

## 1. Purpose
The Topology Discovery Agent discovers structural facts.
It answers: **What exists?**

## 2. Manifest
```yaml
agent_id: "topology_discovery_agent"
version: "0.6.3"
interface_schema_version: "1.0.0"
purpose: "Discover topology, metadata, and relationships through governed command catalogs"
risk_tier: "MEDIUM"
required_roles:
  - "METADATA_READ"
  - "DISCOVERY_EXECUTE"
supported_execution_modes:
  - "DRY_RUN"
  - "SUPERVISED"
  - "AUTONOMOUS_READ_ONLY"
distributed_execution_supported: true
accepted_artifact_types:
  - "bootstrap_readiness_report"
  - "topology_seed"
  - "reusable_discovery_cache"
produced_artifact_types:
  - "topology_graph"
  - "topology_metadata"
  - "topology_evidence"
  - "topology_discovery_report"
  - "reusable_discovery_metadata"
termination_conditions:
  - "scope_exhausted"
  - "budget_exhausted"
  - "policy_limit_reached"
  - "confidence_threshold_satisfied"
  - "operator_stop_request"
  - "unrecoverable_error"
  - "no_valid_next_command"
tool_scope:
  - "registered_connector_commands"
audit_requirements:
  - "decision_log"
  - "command_log"
  - "artifact_log"
```

## 3. Responsibilities
- consuming approved topology_seed and bootstrap_readiness_report
- reasoning over connector command catalogs
- selecting the next approved discovery command
- analyzing command results, errors, confidence, and completeness
- adapting discovery path based on result, confidence, errors, and budget
- emitting topology artifacts and evidence
- logging all decisions, confidence scores, and command selections

## 4. Persistence Boundary
Agent → emits topology artifacts
Runtime → writes graph, evidence, cache

The agent MUST NOT directly write to Graph Store, Evidence Store, or Cache.

## 5. Boundary Rules
The Topology Agent MUST NOT:
- mutate source systems
- execute solution workflows
- validate migration, DR, or backup readiness
- generate connector-specific code
- directly call SQL, REST, MCP, or native connector APIs
- directly invoke another agent
- inspect business data values unless explicitly permitted by connector policy
- persist private state or bypass Runtime mediation
- access cache directly
- directly manage DWE workers, queues, or partitions

## 6. FR-030-A — Result-Aware Discovery Loop
The agent SHALL analyze output, error state, confidence level, and completeness before selecting the next command.
The agent MAY adapt based on discovered entities, partial metadata, errors, permission limits, timeouts, confidence gaps, budget, and scope.
The agent MUST select only registered commands with valid arguments and MUST NOT generate code.

## 7. FR-030-B — Connector-Agnostic Discovery
The agent SHALL operate using connector-exposed command catalogs only.
Connector-specific behavior SHALL be encapsulated within connector implementations.

## 8. FR-030-C — Discovery Termination
Termination occurs on: scope exhausted, budget exhausted, policy limit reached, confidence threshold satisfied, operator stop, unrecoverable error, no valid next command, Runtime context termination.

## 9. FR-030-D — Capability Discovery
Runtime SHALL expose: command names, descriptions, args_schema, result_schema, risk classification, execution backend, execution modes, policy constraints, pagination, sampling, timeout limits, cost estimate.

## 10. FR-030-E — Metadata-Only Discovery
Default: metadata only. Data-value sampling MUST be explicitly policy-approved, audited, and bounded.

## 11. Input Artifacts
- `bootstrap_readiness_report` (overall_status: READY)
- `topology_seed` (targets list)

## 12. Output Artifacts
| Artifact | Description |
|---|---|
| `topology_graph` | Discovered nodes, edges, relationships |
| `topology_metadata` | Schema, table, column, index metadata |
| `topology_evidence` | Raw command results supporting topology claims |
| `topology_discovery_report` | Discovery summary, confidence, termination reason |
| `reusable_discovery_metadata` | Cache-eligible metadata for future workflows |

## 13. Command Catalog Integration
```yaml
connector_profile: "postgres_profile"
commands:
  - command_name: "DISCOVER_SCHEMAS"
    risk_level: "READ_ONLY"
    execution_backend: "LOCAL"
    cost_estimate:
      unit: "discovery_points"
      value: 2
  - command_name: "DISCOVER_TABLES"
    risk_level: "READ_ONLY"
    execution_backend: "LOCAL"
    cost_estimate:
      unit: "discovery_points"
      value: 5
  - command_name: "DISCOVER_COLUMNS_BATCH"
    risk_level: "READ_ONLY"
    execution_backend: "DWE"
    cost_estimate:
      unit: "discovery_points"
      value: 50
    dwe_policy:
      partition_key: "table_name"
      max_workers: 10
      retry_limit: 2
```

## 14. Discovery Loop
```text
Observe last result → Analyze → Select command → Executor validates →
[LOCAL or DWE] → Runtime normalizes → Runtime validates schema →
Runtime persists → Agent reasons → Repeat until termination
```

## 15. Lifecycle
```text
CREATED → READY → RUNNING → WAITING_FOR_ARTIFACT → RUNNING → COMPLETED
```
Exceptional: `RUNNING → FAILED | TERMINATED | PAUSED`

---

**Document Status: FROZEN**
**Repository: `capabilities/topology/`**
**Next Stage: Preflight Validation Agent v0.6.4**

---


**All documents: FROZEN. Ready for implementation.**
