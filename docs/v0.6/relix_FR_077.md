# FR-077 — Agent Execution Modes
## Target Version
v0.6 Intelligent Platform
---
## Scope
Intelligent Platform / Agent Governance / Execution Control
---
## Objective
Define supported execution modes for Relix intelligent agents and establish governance boundaries for autonomous and human-assisted operation.
---
## Overview
Relix agents MAY operate in different execution modes depending on:
- governance policy
- operation sensitivity
- environment configuration
- user permissions
- workflow classification
- RBAC authorization
Execution mode determines how actions are proposed, approved, and executed.
---
## Supported Modes
| Mode | Description |
|---|---|
| Advisory | Agent provides recommendations only |
| Interactive | Human approval required before execution |
| Semi-Autonomous | Selected actions auto-execute under policy |
| Autonomous | Governed workflows execute automatically |
---
## Governance Principle
```text
Agent intelligence does not imply unrestricted execution authority.

All execution modes MUST remain governed by:

* platform constraints
* governance policies
* RBAC authorization
* access-control rules
* audit requirements
* deterministic runtime restrictions

⸻

RBAC Interaction Governance

All agent interactions and executions MUST be RBAC approved.

RBAC policies MUST govern:

* accessible capabilities
* connector visibility
* execution permissions
* approval authority
* workflow initiation
* workflow escalation
* autonomous execution eligibility
* sensitive operation access

Agents MUST operate only within the permissions assigned to the requesting identity and execution context.

⸻

Requirements

FR-077.1 — Advisory Mode

In advisory mode:

* agents MUST NOT execute actions
* agents MAY generate plans/recommendations
* humans remain responsible for execution

⸻

FR-077.2 — Interactive Mode

In interactive mode:

* human approval MUST be required before execution
* approval decisions MUST be auditable
* execution requests MUST be RBAC validated
* agents MAY prepare execution plans

⸻

FR-077.3 — Semi-Autonomous Mode

In semi-autonomous mode:

* approved low-risk actions MAY execute automatically
* sensitive operations MUST require approval
* governance policies MUST define approval thresholds
* RBAC policies MUST determine autonomous eligibility

⸻

FR-077.4 — Autonomous Mode

In autonomous mode:

* agents MAY execute governed workflows automatically
* all operations MUST remain policy validated
* autonomous execution MUST remain auditable
* restricted operations MAY still require escalation
* execution authority MUST remain RBAC constrained

⸻

Restrictions

Agents MUST NOT bypass:

* governance policies
* RBAC controls
* credential boundaries
* audit systems
* runtime constraints
* deterministic execution rules

⸻

Dependencies

Depends on:

* FR-049 — Agent Instruction Hierarchy & Human Override Policy
* FR-066 — Credential-Safe Agent / MCP Database Access
* FR-069 — Policy-Enforced Query Execution Layer
* FR-070 — Auditable Agent Database Operations

