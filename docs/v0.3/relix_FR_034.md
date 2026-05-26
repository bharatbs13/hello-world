FR-XXX — Workflow Execution Telemetry & Metrics Framework
Target Version
v0.3 Core Telemetry Foundation
 
⸻
 
Scope
Platform / Observability
 
⸻
 
Objective
Introduce a reusable workflow execution telemetry framework that captures execution metrics and runtime measurements across workflows, tasks, connectors, checkpoints, reconciliation activities, and runtime planes.
The framework must provide a common telemetry foundation for:
* operational visibility
* workflow progress
* diagnostics
* performance analysis
* future optimization
* future intelligence features
 
⸻
 
Problem Statement
Relix execution can involve multiple stages and execution layers including:
* discovery
* preflight validation
* snapshot execution
* CDC
* reconciliation
* checkpointing
* cutover
* future workflow extensions
Execution spans multiple runtime planes.
Without a common telemetry framework:
* performance bottlenecks become difficult to identify
* workflow failures become harder to diagnose
* execution characteristics remain invisible
* future optimization lacks historical signals
* adaptive intelligence lacks measurable evidence
 
⸻
 
Dependencies
Requires:
* Observability Signal Scope & Identity Contract
 
⸻
 
Architecture
Workflow Execution ↓ Runtime Events ↓ Telemetry Collector ↓ Metrics Store ↓ Observability Services ↓ UI / API / CLI
 
⸻
 
Core Telemetry Categories
Workflow Metrics
Capture:
* workflow start time
* workflow end time
* workflow duration
* workflow status
* workflow completion percentage
* workflow wait time
* workflow queue time
Stage Metrics
Capture:
* stage name
* stage start time
* stage end time
* stage duration
* stage status
Examples:
* discovery
* preflight
* snapshot
* reconciliation
* cutover
Task Metrics
Capture:
* task start time
* task end time
* task duration
* task retry count
* task failure count
* task queue delay
* task execution status
Control Plane Telemetry
Capture:
* workflow scheduling latency
* planner duration
* preflight duration
* approval processing duration
* policy evaluation duration
* API latency
* queue depth
Data Plane Telemetry
Capture:
* connector throughput
* row transfer rate
* batch duration
* checkpoint latency
* worker execution duration
* reconciliation duration
* retry counts
Error Plane Telemetry
Capture:
* validation failures
* connector failures
* retry exhaustion
* checkpoint failures
* reconciliation failures
* policy rejection
* permission denial
* ingestion rejection
* clock skew detection
* preflight failures
* execution failure category
Connector Metrics
Capture:
* connection latency
* query latency
* throughput
* bytes transferred
* rows transferred
* retry count
* connection failures
Checkpoint Metrics
Capture:
* checkpoint creation time
* checkpoint restore time
* checkpoint lag
* checkpoint size
* checkpoint frequency
Reconciliation Metrics
Capture:
* row mismatch count
* checksum mismatch count
* reconciliation duration
* duplicate count
* reconciliation status
Failure Metrics
Capture:
* error type
* failure frequency
* retry frequency
* retry success rate
* failure category
 
⸻
 
Telemetry Plane Rules
Telemetry records must define:
* telemetry_plane
Supported values:
* control_plane
* data_plane
* error_plane
Definitions:
control_plane
→ decision and orchestration behavior
data_plane
→ execution and data movement behavior
error_plane
→ failures, retries, rejections, escalations
Examples:
Validation failure:
record_source_type=runtime
telemetry_plane=error_plane
Connector timeout:
record_source_type=connector
telemetry_plane=error_plane
Retry exhausted:
record_source_type=scheduler
telemetry_plane=error_plane
Rejected observability record:
record_source_type=telemetry_collector
telemetry_plane=error_plane
 
⸻
 
Telemetry Cardinality Rules
Telemetry dimensions and tags must support:
* bounded cardinality
* configurable tag inclusion
* aggregation-safe identifiers
The framework must prevent unbounded dimensions.
Allowed:
* connector_type=postgres
* worker_region=east
Avoid:
* query_text=<full SQL>
* stack_trace=<dynamic content>
* random_request_id=<unique value>
 
⸻
 
Metrics Collection Principles
Telemetry records are append-only.
Underlying storage implementations may support:
* compaction
* aggregation
* retention cleanup
* archival
Telemetry collection must:
* avoid mutating workflow state
* avoid affecting deterministic execution
* support aggregation
* support historical analysis
Telemetry must not become authoritative state.
Authoritative sources:
* event store
* state store
* checkpoint store
 
⸻
 
Acceptance Criteria
1. Workflow metrics are collected.
2. Stage metrics are collected.
3. Task metrics are collected.
4. Control-plane telemetry is collected.
5. Data-plane telemetry is collected.
6. Error-plane telemetry is collected.
7. Connector metrics are collected.
8. Checkpoint metrics are collected.
9. Reconciliation metrics are collected.
10. Failure metrics are collected.
11. Cardinality rules are enforced.
12. Runtime stores remain authoritative.
 
⸻
 
Architectural Rationale
This framework creates a common telemetry foundation before introducing optimization and intelligence capabilities.
Future systems should derive decisions from measured evidence rather than uncontrolled adaptation.
