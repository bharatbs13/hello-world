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