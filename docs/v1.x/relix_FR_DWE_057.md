# Relix FR-DWE-057 — Distributed Progress & Status Model

## Group

DWE Group — State Aggregation & Observability

## Target Version

v1.x

## FR Group

Distributed Workflow Execution (DWE)

## Scope

Platform / Observability Contract

## Core Rule

Observability reflects state.

Observability does not mutate state.

## Scope

* workflow progress
* task progress
* worker progress
* worker health
* checkpoint lag
* retry visibility
* reassignment visibility
* execution timeline

## Acceptance Criteria

1. Workflow progress exists.
2. Task progress exists.
3. Worker progress exists.
4. Health visibility exists.
5. Retry visibility exists.
6. Lag visibility exists.
7. API/UI/CLI consumption is supported.

