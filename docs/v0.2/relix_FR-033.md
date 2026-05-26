# Relix FR-033 — Preflight Workflow Framework

## Owner

v0.2 Runtime

---

## Scope

Platform / Runtime

---

## Status

Proposed

---

## Objective

Introduce a reusable preflight workflow framework that executes validation logic before workflow execution begins.

The framework must support:

- common platform validation
- connector-specific validation
- solution-specific validation
- mandatory and optional validation behavior
- progress event generation
- deterministic result aggregation

The framework must be reusable across all future solutions without requiring core runtime changes.

---

## Problem Statement

Multiple solutions require startup validation before execution.

Examples:

- Migration
- Backup & Recovery (BCR)
- Disaster Recovery (DR)
- Archival
- Maintenance workflows
- Reconciliation workflows

Implementing independent validation logic for each solution creates:

- duplicated code
- inconsistent behavior
- incomplete validation coverage
- poor maintainability
- difficult future extension

Preflight behavior should exist as a platform capability rather than a solution-specific implementation.

---

## Architecture

```text
Workflow
    ↓
Bootstrap
    ↓
PreflightWorkflow
    ├── Common checks
    ├── Connector checks
    ├── Solution checks
    ↓
Aggregate PreflightResult
    ↓
Progress Events
    ↓
Execution Gate
    ↓
Execution Runtime
```

---

## Core Components

Core defines:

- `PreflightWorkflow`
- `PreflightCheck`
- `PreflightSeverity`
- `PreflightRegistry`
- `PreflightResult`
- `RequiredCapability`

---

## Capability Derivation

Preflight must derive required capabilities from the frozen execution plan.

Capabilities must not be hardcoded globally.

Examples:

```text
snapshot_mode: append
    -> WRITE

snapshot_mode: replace
    -> TRUNCATE + WRITE

create_if_missing
    -> CREATE_TABLE + WRITE

checksum enabled
    -> CHECKSUM
```

Preflight must validate only the capabilities required by the selected frozen execution plan.

---

## Validation Categories

### Plan Validation

Checks:

- frozen plan exists
- `workflow_id` exists
- plan consistency
- conflicting option detection

### Dependency Validation

Checks:

- runtime dependencies available
- required services reachable
- endpoint availability

### Connector Validation

Checks:

- connector initialization
- connector compatibility
- credential validation
- capability validation
- permission validation

### Runtime Validation

Checks:

- state store availability
- event store availability
- checkpoint store availability

### Policy Validation

Checks:

- approvals completed
- governance requirements satisfied
- execution window validation

### Solution Validation

Solutions may register checks through:

`SolutionPlugin.register_preflight_checks()`

Examples:

#### Migration

- source schema validation
- destination compatibility
- snapshot permission requirements

#### BCR

- backup target validation
- restore target validation

#### Maintenance

- maintenance window validation
- task dependency validation

---

## Connector Contract

Connectors must expose:

`validate_capabilities(required_capabilities)`

Connector checks remain connector-specific.

Core preflight invokes connector checks only through the connector contract.

Connector responsibilities:

- storage/service validation checks
- capability validation
- permission validation
- backend-specific probes

Solution responsibilities:

- solution-specific validation rules
- workflow-specific checks
- execution-plan-specific requirements

---

## Mandatory vs Optional Checks

Mandatory failure:

```text
Preflight FAIL
Execution blocked
```

Optional failure:

```text
Warning generated
Execution may continue
```

---

## Deterministic Execution

Preflight checks must execute and aggregate results in deterministic registry order.

Result ordering must remain stable across replay for the same frozen execution plan and registered checks.

---

## PreflightResult Shape

Each check result must include at minimum:

### Check-level fields

- `check_id`
- `status`
- `severity`
- `message`
- `required_capability`
- `applies_to`

### Aggregate result fields

- `workflow_id`
- `overall_status`
- `total_checks`
- `passed_checks`
- `failed_checks`
- `warning_checks`

---

## Progress Event Contract

Backend events:

- `PRE_FLIGHT_STARTED`
- `PRE_FLIGHT_CHECK_STARTED`
- `PRE_FLIGHT_CHECK_PASSED`
- `PRE_FLIGHT_CHECK_FAILED`
- `PRE_FLIGHT_CHECK_WARNING`
- `PRE_FLIGHT_COMPLETED`
- `PRE_FLIGHT_BLOCKED`

Purpose:

These events exist as backend contracts for future API/UI/CLI consumers.

v0.2 does not require visualization.

---

## Execution Integration

Execution runtime must consume `PreflightResult`.

If any mandatory check fails:

```text
Execution blocked

PRE_FLIGHT_BLOCKED emitted
```

Optional failures may emit warnings without blocking execution.

---

## v0.2 Deliverables

Implement:

- functional preflight workflow framework
- event generation
- result persistence
- execution gating
- PostgreSQL connector validation implementation

Do NOT implement:

- dashboard rendering
- REST visualization
- AI-generated checks
- automatic remediation
- UI progress bars

---

## Important Design Rules

Allowed:

- `core/preflight/`
- `core/capabilities/`
- `core/runtime/`

Not allowed:

- `migration_preflight`
- `bcr_preflight`
- `snapshot_preflight`

Core runtime remains solution-agnostic.

Solutions extend the framework.

Core runtime does not know solution details.

---

## Non-Goals

Not included:

- execution runtime implementation
- dashboard implementation
- REST API visualization
- AI-generated validation
- automatic remediation
- solution-specific runtime logic

---

## Acceptance Criteria

FR complete when:

1. Preflight workflow framework exists.

2. Mandatory and optional checks are supported.

3. Connector checks are pluggable.

4. Solution plugins can register checks.

5. Results are aggregated deterministically.

6. Execution is blocked on mandatory failure.

7. Progress events are emitted.

8. Existing runtime behavior remains unchanged.

9. Required capabilities are derived from the frozen execution plan.

10. Preflight validates only plan-required capabilities.

11. Checks execute in deterministic registry order.

12. Execution runtime consumes `PreflightResult` before execution begins.

13. Preflight results and event ordering remain deterministic for the same frozen execution plan and registered checks.
