# Relix FR-DEW-058 — Adaptive Worker Capacity Policy

## Group

DWE Group — Optimization & Administrative Control

## Target Version

v1.x

## FR Group

Distributed Workflow Execution (DWE)

## Scope

Platform / Runtime Optimization

## Core Rule

Metrics recommend.

Configuration constrains.

Controller decides.

Runtime executes.

## Signals

* queue depth
* backlog
* checkpoint lag
* worker health
* throughput
* failure rate
* retry rate
* utilization
* SLA pressure

## Acceptance Criteria

1. Capacity is the scaling target.
2. Infrastructure count is not the scaling target.
3. Scaling recommendations use metrics.
4. Min/max limits are enforced.
5. Cooldown policies are enforced.
6. Controller owns final decisions.

