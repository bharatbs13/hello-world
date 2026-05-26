FR-036 — Solution Wrapper & Workflow Composition Framework
Target Version
v0.4 Human Workflow Platform

Scope
Platform / Workflow Composition

Objective
Provide reusable solution wrappers that compose deterministic workflow primitives into solution-specific workflows.
The framework must allow future solutions to reuse shared workflow components while preserving deterministic execution behavior.

Problem Statement
Relix runtime exposes reusable workflow primitives:
* discovery
* validation
* snapshot
* CDC
* reconciliation
* checkpointing
* cutover
Future solutions may require different arrangements of these primitives.
Examples:
Migration
Discovery ↓ Preflight ↓ Snapshot ↓ CDC ↓ Reconciliation ↓ Cutover
Backup & Recovery
Backup ↓ Validation ↓ Restore ↓ Verification
Without reusable wrappers:
* workflow logic becomes duplicated
* solution evolution becomes difficult
* configuration reuse becomes inconsistent
* future solution expansion becomes harder

Architecture
Workflow Primitives ↓ Solution Wrapper ↓ Workflow Composition ↓ Runtime Execution

Capabilities
* workflow composition
* solution wrappers
* reusable workflow templates
* workflow dependency management
* workflow configuration injection
* workflow lifecycle composition

Wrapper Versioning
Solution wrappers must support:
* wrapper_version
Optional:
* parent_wrapper_version
Purpose:
Track wrapper evolution lineage.
Examples:
Migration Wrapper v3
parent_wrapper_version = v2

Compatibility Rules
Wrapper versions may support:
* backward compatible changes
* additive capabilities
Wrapper versions must not:
* require modification of previously approved workflow definitions
* invalidate existing workflow definitions

Execution Boundary Rules
Solution wrappers may:
* compose workflow primitives
* inject configuration
* define workflow ordering
Solution wrappers must not:
* alter deterministic runtime behavior
* bypass validation
* mutate checkpoint logic
* modify reconciliation rules

Acceptance Criteria
1. Workflow primitives are reusable.
2. Solution wrappers support composition.
3. Workflow configuration injection is supported.
4. Workflow lifecycle composition is supported.
5. Wrapper versioning is supported.
6. Compatibility rules are defined.
7. Runtime behavior remains deterministic.

Architectural Rationale
Solution wrappers create reusable composition logic while preserving runtime ownership and deterministic execution.
