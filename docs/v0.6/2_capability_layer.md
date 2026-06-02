
# Document 2: Capability Layer Overview v0.6.1

**File:** `docs/architecture/capability-layer-overview-v0.6.1.md`

---

# Relix Capability Layer Overview v0.6.1

**Status: FROZEN**
**Version: v0.6.1**
**Type: Architecture Document**
**Scope: High-level flow, version structure, and inter-agent relationships**

## 1. Purpose
This document provides the high-level overview of the Relix v0.6.x agentic capability layer.
For core modules, see `agentic-runtime-foundation-v0.6.0.md`.
For agent-specific details, see individual agent documents.

## 2. Version Structure
| Version | Layer | Type | Primary Question |
|---|---|---|---|
| `v0.6.0` | Common Agentic Runtime Foundation | Architecture | How do agents operate safely? |
| `v0.6.1` | Capability Layer Overview | Architecture | How do capabilities compose? |
| `v0.6.2` | Bootstrap Readiness Agent | Agent | Can discovery begin? |
| `v0.6.3` | Topology Discovery Agent | Agent | What exists? |
| `v0.6.4` | Preflight Validation Agent | Agent | Is it ready for a solution? |

## 3. Module Map
| Module | Path | Type |
|---|---|---|
| Agent Lifecycle | `core/agents` | Module |
| Runtime | `core/runtime` | Module |
| Executor | `core/executor` | Module |
| Artifacts | `core/artifacts` | Module/Schema |
| Errors | `core/errors` | Module/Schema |
| Confidence | `core/confidence` | Module/Schema |
| Isolation | `core/isolation` | Module |
| Cache | `core/cache` | Module |
| Connectors | `core/connectors` | Module |
| DWE | `core/dwe` | Module |
| Audit | `core/audit` | Module |
| Policy | `core/policy` | Module |
| Bootstrap Agent | `capabilities/bootstrap` | Agent |
| Topology Agent | `capabilities/topology` | Agent |
| Preflight Agent | `capabilities/preflight` | Agent |

## 4. Core Principle
```text
connector catalog → governed agent reasoning loop
```

## 5. Responsibility Separation
| Concern | Owner | Plane |
|---|---|---|
| Safety enforcement | Runtime / Executor | Governance Bridge |
| Capability exposure | Connector Catalog | Control |
| Command execution (local) | Connector Implementation | Execution |
| Distributed execution | DWE Workers | Execution |
| Sequencing | Agent | Control |
| Persistence | Runtime | Governance Bridge |
| Cache | Runtime | Governance Bridge |
| Governance | Policy / Budget / Audit Layer | Governance Bridge |

## 6. End-to-End Capability Flow
```text
[Trigger Run]
      ↓
[Bootstrap Readiness Agent v0.6.2]
      ↓
bootstrap_readiness_report
      ↓
[Topology Discovery Agent v0.6.3]
      ↓
topology_graph
topology_metadata
topology_evidence
topology_discovery_report
      ↓
[Preflight Validation Agent v0.6.4]
      ↓
preflight_validation_report
```

## 7. Agent Communication Pattern
```text
Bootstrap Readiness Agent
  ↓ emits bootstrap_readiness_report
Runtime
  ↓ validates, stores, audits
Topology Discovery Agent
  ↓ consumes bootstrap_readiness_report + topology_seed
Topology Discovery Agent
  ↓ emits topology_graph, topology_metadata, topology_evidence, topology_discovery_report
Runtime
  ↓ validates, stores, audits
Preflight Validation Agent
  ↓ consumes topology_graph, topology_metadata, solution_context, execution_plan
```

Agents never communicate directly. All communication is Runtime-mediated through artifacts.

## 8. Discovery Loop (v0.6.3)
```text
Observe last command result (from Runtime-validated context)
        ↓
Analyze structure, error, confidence, completeness
        ↓
Select next approved command
        ↓
Executor validates command, args, policy, budget, isolation, execution backend
        ↓
[LOCAL] → Connector executes command
[DWE]   → DWE Adapter maps to jobs → DWE Workers execute → Runtime collects
        ↓
Runtime normalizes result
        ↓
Runtime validates result against result_schema
        ↓
Runtime persists artifacts and updates cache
        ↓
Agent reasons over updated state
        ↓
Repeat until termination condition
```

## 9. Deterministic Boundaries
Relix discovery is deterministic in: command exposure, validation, argument schemas, result schemas, result schema validation, policy checks, risk checks, budget checks, tenant/workflow isolation, audit logging, persistence boundaries, cache mediation, execution boundaries, DWE result mediation.

## 10. Agentic Boundaries
Relix discovery is agentic in: command sequencing, result interpretation, branch selection, error recovery, depth control, confidence evaluation, stop condition reasoning.

## 11. v0.6 Scope
v0.6.x defines independent capability agents only.
Workflow composition and solution workflows belong to later versions.

---

**Document Status: FROZEN**
**Related Documents:**
- `agentic-runtime-foundation-v0.6.0.md`
- `bootstrap-readiness-agent-v0.6.2.md`
- `topology-discovery-agent-v0.6.3.md`
- `preflight-validation-agent-v0.6.4.md`

---

