| FR | Title |
|---|---|
| FR-079 | Agent Registry & Lifecycle Management |
| FR-080 | Workflow Definition & Orchestration Model |
| FR-081 | Agent Context & Execution State Management |
| FR-082 | Governed Capability Contract Model |
| FR-083 | Workflow Failure Handling & Recovery |
| FR-084 | Agent Observability & Telemetry |
| FR-085 | Tenant & Workspace Isolation |
| FR-086 | LLM Provider & Model Routing Abstraction |
| FR-087 | Deterministic Workflow Execution Strategy |
| FR-088 | Agent & Workflow Testing Framework |
| FR-089 | RBAC-Based Agent Interaction & Execution Control |

| FR | UI Impact |
|---|---|
| FR-077 Agent Execution Modes | Mode selector: advisory / interactive / semi-autonomous / autonomous |
| FR-078 Agent Deployment & Communication | Admin config UI for deploy mode, endpoint, queue, MCP server |
| FR-079 Agent Registry & Lifecycle | Agent catalog, enable/disable, version, health, capability view |
| FR-080 Workflow Definition & Orchestration | Workflow designer, step graph, dependency view, approval checkpoints |
| FR-081 Agent Context & Execution State | Session/context viewer, memory/state inspection, expiry controls |
| FR-082 Governed Capability Contract | Capability catalog, input/output schema viewer, test invocation UI |
| FR-083 Workflow Failure Handling | Retry, rollback, compensation, escalation, dead-letter queue UI |
| FR-084 Observability & Telemetry | Dashboard for metrics, traces, latency, cost, agent performance |
| FR-085 Tenant & Workspace Isolation | Workspace switcher, tenant admin, isolated connector/agent views |
| FR-086 LLM Provider & Model Routing | Model/provider config UI, routing rules, fallback, cost limits |
| FR-087 Deterministic Workflow Execution | Frozen plan viewer, replay UI, approved snapshot comparison |
| FR-088 Agent & Workflow Testing | Test console, mock connector setup, dry-run, simulation, golden tests |
| FR-089 RBAC Agent Control | Role/permission matrix, approval authority, capability access UI |

Highest UI impact:

| Priority | UI Area |
|---|---|
| 1 | Workflow designer / execution monitor |
| 2 | Agent registry / capability catalog |
| 3 | RBAC + approval management |
| 4 | Observability dashboard |
| 5 | Testing / simulation console |


Yes — DWE becomes the execution substrate for distributed agents.

Relix Control Plane
  ↓
Agent Gateway
  ↓
DWE Distributed Worker Engine
  ↓
Agent Worker Services
  ↓
Connectors / APIs / DB / Storage

So agents are not just “chat objects.” In mature Relix, they become a cluster of governed worker services.

| Layer | Role |
|---|---|
| Agent Gateway | Receives agent invocation and normalizes contract |
| DWE | Dispatches jobs, schedules workers, handles retries/timeouts |
| Agent Worker | Runs specialized task agent logic |
| Governance Layer | RBAC, policy, audit, credentials |
| Connector Layer | Executes DB/API/dlt/custom REST operations |

Adoption model:

| Stage | Agent Deployment |
|---|---|
| v0.6 | agents as in-process modules |
| v0.7 | agents can run as DWE workers |
| v0.8+ | agents form distributed service clusters |

Design principle:

Agent = logical capability.
DWE worker = physical execution unit.

So one migration_agent may run as:

migration_agent
  ├── planner worker
  ├── schema inspection worker
  ├── dry-run worker
  ├── execution worker
  └── reconciliation worker

This fits very well with DWE.

You can add an FR:

# FR-090 — Distributed Agent Execution via DWE
## Target Version
v0.7
## Scope
Agent Runtime / Distributed Worker Execution
## Objective
Enable Relix agents to execute as distributed worker services through the DWE framework.
## Requirement
Relix MUST support mapping governed agent invocations to DWE jobs, workers, queues, retries, timeouts, and execution state while preserving RBAC, policy validation, audit logging, and credential-safety boundaries.
## Core Principle
Agent identity is logical.
Worker execution is physical.