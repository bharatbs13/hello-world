# FR-078 — Configurable Agent Deployment & Communication Architecture
## Target Version
v0.6 Intelligent Platform
---
## Scope
Intelligent Platform / Agent Runtime / Deployment Architecture
---
## Objective
Define a deployment-independent architecture for Relix agents where deployment mode and communication mechanism are configurable and governable.
This FR enables Relix agents to operate:
- as in-process modules
- as independent services
- as worker processes
- as MCP-connected runtimes
- as scheduled/background execution units
without changing workflow logic or governance behavior.
---
## Core Principle
```text
Same agent contract.
Different deployment mode.
Different communication mechanism.

Relix workflows MUST remain deployment-independent.

⸻

High-Level Architecture

Relix Workflow Engine
        ↓
Agent Gateway
        ↓
Communication Adapter
        ↓
Agent Runtime

The Agent Gateway resolves deployment mode and communication strategy dynamically.

⸻

Supported Deployment Modes

Deploy Mode	Description
in_process	Agent executes inside Relix process
service	Agent executes as independent API service
worker	Agent executes through async queue/job system
mcp	Agent executes through MCP protocol
scheduled	Agent executes through scheduler/event trigger
container_job	Agent executes as isolated runtime job

⸻

Supported Communication Mechanisms

Communication Type	Description
direct_call	In-memory function/class invocation
rest	REST-based communication
grpc	gRPC communication
queue	Queue/pub-sub/job broker communication
mcp	MCP protocol communication
event_bus	Event-driven messaging
artifact_exchange	File/object/artifact-based exchange

⸻

Requirements

FR-078.1 — Deployment Independence

Relix workflows MUST NOT depend directly on agent deployment type.

Workflow logic MUST remain independent of:

* process boundary
* transport protocol
* runtime location
* infrastructure topology

⸻

FR-078.2 — Agent Gateway

Relix MUST provide an Agent Gateway abstraction responsible for:

* deployment resolution
* communication routing
* transport abstraction
* request dispatch
* response normalization
* failure handling
* timeout enforcement

⸻

FR-078.3 — Config-Driven Deployment

Agent deployment mode MUST be configurable.

Configuration SHOULD support:

* enabled/disabled state
* deploy mode
* communication mechanism
* endpoint/queue/server metadata
* RBAC restrictions
* execution policy
* timeout/retry configuration

Example:

agents:
  migration_agent:
    deploy_mode: in_process
    communication: direct_call
  backup_agent:
    deploy_mode: worker
    communication: queue
  discovery_agent:
    deploy_mode: service
    communication: rest

⸻

FR-078.4 — Unified Agent Contract

All agents MUST expose a normalized execution contract independent of deployment mode.

Example conceptual contract:

AgentInput → AgentOutput

The contract SHOULD support:

* structured inputs
* structured outputs
* execution metadata
* execution status
* error reporting
* audit correlation IDs

⸻

FR-078.5 — Governance Consistency

All deployment modes MUST remain governed by:

* RBAC authorization
* policy validation
* credential-safety rules
* audit logging
* execution restrictions
* deterministic workflow constraints

Changing deployment mode MUST NOT bypass governance.

⸻

FR-078.6 — Communication Adapter Abstraction

Communication mechanisms MUST be abstracted through communication adapters.

Adapters MAY include:

* REST adapter
* gRPC adapter
* queue adapter
* MCP adapter
* direct-call adapter
* event-bus adapter

Relix SHOULD support adding new adapters without modifying workflow logic.

⸻

FR-078.7 — Failure Isolation

Relix SHOULD support isolation boundaries between agents.

Independent deployment modes MAY provide:

* fault isolation
* resource isolation
* scaling isolation
* retry isolation
* runtime version isolation

⸻

Design Principle

Build modular first.
Deploy distributed later.

⸻

Dependencies

Depends on:

* FR-065 — Governed Agent Capability Discovery
* FR-066 — Credential-Safe Agent / MCP Database Access
* FR-077 — Agent Execution Modes

