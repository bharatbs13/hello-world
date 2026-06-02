# Document 1: Agentic Runtime Foundation v0.6.0

**File:** `docs/architecture/agentic-runtime-foundation-v0.6.0.md`

---

# Relix Agentic Runtime Foundation v0.6.0

**Status: FROZEN**
**Version: v0.6.0**
**Type: Architecture Document**
**Scope: Core modules governing all Relix agents**

## 1. Purpose
This document defines the core modules, contracts, and boundaries that govern all Relix agents.
This is the invariant base. Agent-specific behavior is defined in individual agent documents.

## 2. Module Map
| Module | Path | Type | Description |
|---|---|---|---|
| Agent Lifecycle | `core/agents` | Module | State machine, manifest schema |
| Runtime | `core/runtime` | Module | AgentRunContext, artifact persistence, cache ownership |
| Executor | `core/executor` | Module | Command validation, DWE adapter, policy enforcement |
| Artifacts | `core/artifacts` | Module/Schema | Artifact contract, authority rule |
| Errors | `core/errors` | Module/Schema | Error taxonomy |
| Confidence | `core/confidence` | Module/Schema | Confidence scoring model |
| Isolation | `core/isolation` | Module | Tenant/workflow isolation enforcement |
| Cache | `core/cache` | Module | Cache governance, TTL, scoping rules |
| Connectors | `core/connectors` | Module | Connector capability contract, MCP placement, onboarding |
| DWE | `core/dwe` | Module | DWE adapter boundary, job submission |
| Audit | `core/audit` | Module | Decision audit trail, command logging |
| Policy | `core/policy` | Module | RBAC, budget, risk tier enforcement |

## 3. Core Architectural Principle
```text
Agent = Planner / Reasoner (Control Plane)
Runtime = Authority
Executor = Enforcer
Connector = Performer
DWE = Scalable Execution Substrate (Data Plane / Execution Plane)
Artifact = Communication Boundary
Cache = Runtime-Owned Mediated Context
```

## 4. Plane Separation
```text
Control Plane (Agents)
  - Decide what should happen
  - Reason over results
  - Adapt discovery path
  - Emit execution intents and artifacts

Data Plane / Execution Plane (DWE)
  - Execute distributed workloads
  - Handle worker scheduling, queues, retries
  - Process partitioned workloads
  - Report execution telemetry

Runtime (Governance Bridge)
  - Validates policy, budget, RBAC
  - Maps agent intents to DWE jobs
  - Normalizes and validates results
  - Persists artifacts and cache
  - Enforces tenant/workflow isolation
  - Logs all decisions for audit
```

## 5. Tenant and Workflow Isolation Boundary
**Module: `core/isolation`**

Every agent run SHALL be scoped by:
- `tenant_id`, `workflow_id`, `run_id`, `policy_id`, `connector_profile_id`

The Runtime SHALL ensure that artifacts, cache entries, graph writes, evidence records, audit logs, command results, DWE job metadata, and AgentRunContext values are partitioned by tenant and workflow scope.

Agents MUST NOT read, infer from, or reuse artifacts outside their authorized tenant and workflow scope.

Cross-workflow reuse MAY occur only through Runtime-approved reusable cache metadata and MUST satisfy:
- same `tenant_id`, compatible `policy_id`, compatible `connector_profile_id`
- compatible artifact schema version, freshness TTL, explicit cache-governance approval

Cross-tenant reuse is prohibited by default.

## 6. Agent Communication Model
**Governed by: `core/runtime`, `core/artifacts`**

Agents MUST NOT communicate directly with other agents.

```text
Agent A → emits artifact → Runtime → validates + persists → Artifact Store
                                                                    ↓
Agent B ← consumes approved artifact ← Runtime ← makes artifact available
```

## 7. Artifact Authority Rule
**Module: `core/artifacts`**

Artifacts are the sole authority for inter-agent state transfer.
Agents SHALL NOT rely on: in-memory state, direct API calls to other agents, shared mutable state, hidden runtime variables, or direct DWE result access.

## 8. Agent Lifecycle State Machine
**Module: `core/agents`**

```text
CREATED → READY → RUNNING → WAITING_FOR_ARTIFACT → RUNNING → COMPLETED
```

Exceptional paths:
```text
RUNNING → FAILED
RUNNING → TERMINATED
RUNNING → PAUSED
```

| State | Meaning |
|---|---|
| `CREATED` | Agent instantiated but not yet validated |
| `READY` | Agent validated, awaiting AgentRunContext |
| `RUNNING` | Agent executing its reasoning loop |
| `WAITING_FOR_ARTIFACT` | Agent paused, awaiting Runtime-mediated artifact availability |
| `COMPLETED` | Agent terminated successfully, artifacts emitted |
| `FAILED` | Agent terminated with unrecoverable error |
| `TERMINATED` | Agent stopped by operator or policy |
| `PAUSED` | Agent suspended by operator, resumable |

## 9. Agent Manifest Schema
**Module: `core/agents`**

```yaml
agent_id: "string"
version: "semver"
interface_schema_version: "semver"
purpose: "string"
risk_tier: "LOW | MEDIUM | HIGH"
required_roles:
  - "ROLE_NAME"
supported_execution_modes:
  - "DRY_RUN"
  - "SUPERVISED"
  - "AUTONOMOUS_READ_ONLY"
distributed_execution_supported: true | false
accepted_artifact_types:
  - "artifact_type_name"
produced_artifact_types:
  - "artifact_type_name"
termination_conditions:
  - "CONDITION_NAME"
tool_scope:
  - "registered_command_name"
audit_requirements:
  - "decision_log"
  - "command_log"
  - "artifact_log"
```

## 10. Artifact Contract
**Module: `core/artifacts`**

```yaml
artifact_id: "uuid"
tenant_id: "string"
workflow_id: "uuid"
run_id: "uuid"
artifact_type: "string"
producer_agent_id: "string"
artifact_schema_version: "semver"
timestamp: "ISO-8601"
confidence:
  score: 0.95  # Normalized to [0.0, 1.0]
  factors:
    schema_conformance: 1.0
    error_free: 1.0
    completeness: 0.8
    freshness: 1.0
payload: {}
```

## 11. AgentRunContext
**Module: `core/runtime`**

```yaml
agent_run_context:
  run_id: "uuid"
  workflow_id: "uuid"
  tenant_id: "string"
  agent_id: "string"
  policy_id: "string"
  connector_profile_id: "string"
  budget_remaining:
    discovery_points: 1000
    time_seconds: 3600
  execution_mode: "SUPERVISED"
  accepted_artifacts:
    - artifact_id: "uuid"
      artifact_type: "artifact_type_name"
  cache_context:
    allowed_cache_scopes:
      - "WORKFLOW"
      - "REUSABLE_DISCOVERY"
    provided_cache_entries:
      - cache_entry_id: "uuid"
        cache_scope: "WORKFLOW"
        artifact_type: "artifact_type_name"
        confidence_score: 0.95
  dwe_context:
    dwe_enabled: true
    max_workers: 10
    partition_key: "string"
    retry_limit: 2
```

## 12. Workflow-Scoped Command and Artifact Cache
**Module: `core/cache`**

The Runtime MAY cache successful command results and validated artifacts for reuse within the same workflow.

Every cache entry SHALL include: `tenant_id`, `workflow_id`, `run_id`, `agent_id`, `connector_profile_id`, `command_name`, `command_args_hash`, `result_schema_version`, `artifact_schema_version`, `policy_id`, `created_at`, `expires_at`, `confidence_score`.

Agents SHALL NOT access cache directly.
The Runtime SHALL expose only authorized cache entries through `AgentRunContext.cache_context`.

**Principle:** Cache is Runtime-owned. Agents receive cache as mediated context. Reuse is scoped by tenant, workflow, policy, connector profile, schema version, and TTL.

## 13. Execution Modes
**Governed by: `core/runtime`, `core/policy`**

| Mode | Mutating Allowed | Behavior |
|---|---|---|
| `DRY_RUN` | No | Validate without execution |
| `SUPERVISED` | Depends on command | Operator visibility and oversight enabled |
| `AUTONOMOUS_READ_ONLY` | No | Execute non-mutating commands autonomously |

## 14. Error Taxonomy
**Module: `core/errors`**

Used by: agents, runtime, executor, connectors.

| Error Class | Agent Behavior |
|---|---|
| `RECOVERABLE` | Retry with backoff, bounded by policy |
| `UNRECOVERABLE` | Terminate current scope |
| `POLICY_DENIED` | Log, skip resource, continue if possible |
| `BUDGET_EXHAUSTED` | Terminate gracefully |
| `PERMISSION_LIMITED` | Log partial result, continue with reduced scope |
| `CONFIDENCE_GAP` | Lower confidence score, request supervision |

## 15. Confidence Scoring
**Module: `core/confidence`**

```yaml
confidence:
  score: 0.95  # Normalized to [0.0, 1.0]
  factors:
    schema_conformance: 1.0
    error_free: 1.0
    completeness: 0.8
    freshness: 1.0
```

## 16. Command Risk Levels
**Governed by: `core/policy`**

| Risk Level | Meaning |
|---|---|
| `READ_ONLY` | Metadata-only or non-mutating read operation |
| `LOW_RISK` | Non-mutating probe with limited operational impact |
| `MEDIUM_RISK` | Non-mutating operation with measurable cost, latency, or endpoint pressure |
| `HIGH_RISK` | Potentially disruptive, expensive, broad, or sensitive operation |

## 17. Cost Estimate Structure
**Module: `core/policy`**

```yaml
cost_estimate:
  unit: "discovery_points"
  value: 5
```

## 18. Command Execution Backend
**Module: `core/dwe`**

```yaml
execution_backend: "LOCAL" | "DWE"

# DWE-enabled commands include:
dwe_policy:
  partition_key: "string"
  max_workers: 10
  retry_limit: 2
```

## 19. Runtime and Executor Responsibilities
**Module: `core/executor`**

Before execution, the Executor MUST validate:
- command is registered and allowed for connector profile
- arguments match args_schema, result schema is known
- policy permits command execution, budget remains available
- command risk tier is allowed, secrets are not exposed
- tenant and workflow isolation is enforced
- DWE job submission is authorized (if applicable)
- audit event can be recorded

After execution, the Runtime SHALL validate:
- result conforms to declared result_schema
- DWE results pass through Runtime before agent visibility

## 20. FR-030-F — Connector Capability Contract
**Module: `core/connectors`**

A connector SHALL expose its supported command catalog, argument schemas, result schemas, risk classifications, execution constraints, and execution backend preference through a standardized capability contract.
Agents SHALL reason only over this contract.

## 21. Connector Onboarding Requirements
**Module: `core/connectors`**

A connector SHALL NOT be eligible for Runtime registration unless:
- command catalog exists
- args_schema exists for every command
- result_schema exists for every command
- risk classification exists for every command
- execution backend defined for every command
- audit metadata defined for every command

## 22. FR-030-G — Result Schema Validation
**Module: `core/executor`**

The Runtime SHALL validate command results against the declared result_schema before exposing the result to any agent.
Results that fail schema validation SHALL be classified as `CONFIDENCE_GAP` or `UNRECOVERABLE`.
Applies to both local and DWE-executed commands.

## 23. FR-110-A — Mediation Constraint
**Governed by: `core/runtime`**

Agents MUST NOT invoke other agents directly.
All inter-agent communication MUST occur through Runtime-mediated artifacts.

## 24. Decision Audit Trail
**Module: `core/audit`**

Agents SHALL log: command selections, confidence evaluations, path adaptations, termination evaluations, error classifications, lifecycle transitions.

Runtime SHALL additionally log: DWE job submissions and results, job id, partitions, retries, final status.

## 25. MCP Placement
**Module: `core/connectors`**

MCP MAY be used as a connector implementation backend.
MCP MUST NOT be exposed directly as the agent planning layer.

```text
Agent → selects approved Relix command
Executor → validates command and policy
Connector Gateway → maps Relix command to native connector or MCP tool
MCP Server → executes approved backend tool
```

---

**Document Status: FROZEN**
**Applies to: All Relix v0.6.x agents**

---

