# FR-090 — Agent-Orchestrated DWE Execution

## Target Version

v0.7

---

## Scope

Intelligent Platform / Workflow Execution / DWE Integration

---

## Objective

Enable Relix agents to initiate, supervise, monitor, and govern execution performed by the Distributed Worker Engine (DWE).

Agents provide planning, validation, governance, and supervision capabilities, while DWE performs deterministic distributed execution.

---

## Requirement

Relix MUST support the handoff of approved execution plans from intelligent agents to DWE for distributed execution.

Relix MUST support:

- execution plan submission
- worker allocation
- queue assignment
- execution monitoring
- retry management
- timeout handling
- progress tracking
- failure reporting
- reconciliation triggers
- execution completion reporting

while preserving:

- RBAC authorization
- policy validation
- audit logging
- credential-safety controls
- workflow determinism

---

## Responsibilities

### Agent Responsibilities

Agents MAY perform:

- workflow planning
- connector discovery
- schema analysis
- preflight validation
- risk assessment
- execution supervision
- failure explanation
- remediation recommendation

Agents SHOULD NOT perform bulk data movement.

---

### DWE Responsibilities

DWE MUST perform:

- work partitioning
- worker scheduling
- queue management
- distributed execution
- retry handling
- timeout handling
- progress reporting
- workload distribution

DWE workers SHOULD execute deterministic workloads.

---

## Core Principle

```text
Agents plan and govern.

DWE executes.
