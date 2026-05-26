# Relix FR-DWE-056 — Distributed Reconciliation Aggregation

## Group

DWE Group — State Aggregation & Observability

## Target Version

v1.x

## FR Group

Distributed Workflow Execution (DWE)

## Scope

Platform / Reconciliation

## Core Rule

Reconciliation outcomes are aggregated from authoritative task outcomes.

## Scope

* partition reconciliation outcomes
* mismatch aggregation
* completeness checks
* failed partition visibility

## Acceptance Criteria

1. Partition reconciliation exists.
2. Workflow reconciliation can be derived.
3. Failed partitions are visible.
4. Reconciliation state is reconstructable.

