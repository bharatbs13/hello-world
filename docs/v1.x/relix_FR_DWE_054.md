# Relix FR-DWE-054 — Distributed Task Lifecycle & Recovery Contract

## Group

DWE Group — Foundation Runtime Contracts

## Target Version

v1.x

## FR Group

Distributed Workflow Execution (DWE)

## Scope

Platform / Distributed Runtime

## Objective

Provide canonical lifecycle semantics for distributed task partitions.

## Lifecycle Model

```text
planned
    ↓
assigned
    ↓
running
    ↓
completed

assigned
    ↓
lease_expired
    ↓
reassigned

running
    ↓
failed
    ↓
retry_pending
```

## Transition Rules

Allowed:

```text
planned
    ↓
assigned

assigned
    ↓
running

running
    ↓
completed

running
    ↓
failed

assigned
    ↓
lease_expired
    ↓
reassigned

failed
    ↓
retry_pending
    ↓
assigned
```

Prohibited:

```text
completed
    ↓
running

completed
    ↓
failed

running
    ↓
planned

reassigned
    ↓
planned
```

## Late Result Rules

Events emitted by non-owning workers must not become authoritative.

Examples:

* checkpoint updates
* task completion
* reconciliation outcomes

Late results may:

* be recorded
* be audited

Late results must not:

* overwrite active ownership state

## Core Rule

Task state transitions are authoritative for recovery behavior.

## Acceptance Criteria

1. Lifecycle states are defined.
2. Recovery states are defined.
3. Transition legality is defined.
4. Retry behavior is deterministic.
5. Recovery eligibility is visible.
6. Invalid transitions are prohibited.
7. Late worker results cannot become authoritative.

