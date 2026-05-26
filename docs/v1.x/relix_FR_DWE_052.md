# Relix FR-DWE-052 — Logical Worker Model, Lease & Heartbeat

## Group

DWE Group — Foundation Runtime Contracts

## Target Version

v1.x

## FR Group

Distributed Workflow Execution (DWE)

## Scope

Platform / Distributed Runtime

## Objective

Model workers as logical execution entities and provide lease and heartbeat mechanisms for safe distributed ownership.

## Worker Model

Workers are logical execution entities.

Workers do not map one-to-one with:

* VM
* container
* process
* thread

Runtime implementations may use:

* threads
* processes
* containers
* Kubernetes pods
* serverless tasks
* distributed nodes

Coordinator reasoning occurs in terms of:

* worker capacity
* available slots
* assigned tasks
* lease ownership
* heartbeat health

## Ownership Transfer Rules

Ownership transfer must be atomic.

At any point in time:

* a task partition may have at most one active owner

Lease expiry must invalidate prior ownership before new ownership becomes active.

Workers with expired ownership must not:

* emit checkpoint updates
* emit completion events
* mutate task state

## Core Rule

A task partition must have one active logical owner.

## Scope

* logical worker model
* worker capacity model
* available slot tracking
* worker lease model
* lease renewal
* lease expiry
* heartbeat tracking
* stale worker detection
* ownership transfer

## Acceptance Criteria

1. Workers are represented as logical entities.
2. Worker capacity is independent of infrastructure count.
3. Worker leases prevent duplicate ownership.
4. Lease renewal is supported.
5. Lease expiry is detectable.
6. Worker heartbeats are tracked.
7. Stale workers are detectable.
8. Ownership transfer is safe.
9. Ownership transfer is atomic.
