# Relix FR-DWE-053 — Distributed Coordinator & Task Assignment

## Group

DWE Group — Foundation Runtime Contracts

## Target Version

v1.x

## FR Group

Distributed Workflow Execution (DWE)

## Scope

Platform / Distributed Runtime

## Objective

Enable workflow partitioning and coordination through a core-controlled coordinator.

## Core Rule

Controller coordinates.

Workers execute.

## Scope

* controller/coordinator model
* task planner
* task assignment
* task lifecycle tracking
* retry flow
* reassignment flow
* duplicate prevention
* coordinator-owned decisions

## Coordinator Authority Rules

Coordinator decisions must be reconstructable from authoritative records.

Coordinator-local memory must not become authoritative.

Examples:

* assignment decisions
* reassignment decisions
* retry decisions
* ownership transfers

must remain replay-safe.

## Coordinator Ownership Rules

Only one coordinator instance may act as active coordinator for a workflow at a given time.

Coordinator failover must preserve:

* assignment history
* ownership state
* retry state
* reassignment state

Coordinator replacement must reconstruct state from authoritative records.

## Acceptance Criteria

1. Coordinator model exists.
2. Tasks can be planned.
3. Tasks can be assigned.
4. Coordinator owns assignments.
5. Failed tasks can be reassigned.
6. Duplicate assignments are prevented.
7. Workers do not own workflow state.
8. Coordinator decisions are replay-safe.
9. Coordinator restart does not lose ownership state.
10. Active coordinator uniqueness is enforced.

