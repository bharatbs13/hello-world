# RXTA v0.2.1 Framework Capability Overview

## Purpose

RXTA (Relix Validation and Benchmark Automation Framework) is a catalog-driven validation platform that provides deployment automation, execution planning, topology-aware validation, benchmark orchestration, reporting, aggregation, diagnostics, and governance.

The framework evolved significantly from v0.2.0 and now operates as a solution-aware validation platform rather than a collection of deployment and test scripts.

---

# High-Level Architecture

```text
CLI
  ↓
Prompt Resolution
  ↓
Version Governance
  ↓
Suite Selection
  ↓
Infrastructure Selection
  ↓
Topology Planning
  ↓
Execution Identity
  ↓
Functional / Benchmark Matrix Expansion
  ↓
Runtime Execution
  ↓
Pytest Report Integration
  ↓
Aggregation
  ↓
Diagnostics
  ↓
Governance & Regression Management
```

---

# automation/

The automation package contains operational tooling used to prepare environments and manage deployments.

## automation/db_setup/postgres/

### seed_data.py

Purpose:

* deterministic PostgreSQL seed data generation
* customer and order sample datasets
* reusable setup support for validation environments

Responsibilities:

* seed generation
* repeatable test data creation

---

### setup_phase2.py

Purpose:

* Phase 2 environment preparation

Responsibilities:

* create PostgreSQL schemas
* create validation tables
* populate seed data
* prepare real infrastructure validation environments

---

### teardown_phase2.py

Purpose:

* cleanup Phase 2 environments

Responsibilities:

* truncate validation data
* optional schema removal
* restore clean validation state

---

## automation/deploy/

### relix_deploy.py

Purpose:

Legacy deployment orchestration utility.

Responsibilities:

* deploy
* start
* stop
* delete
* test execution
* report directory management
* source resolution
* secret masking

---

### verify_runtime.py

Purpose:

Runtime readiness validation.

Responsibilities:

* configuration validation
* database connectivity checks
* environment verification

---

# relix_tools/

Core RXTA framework implementation.

---

# benchmark/

Benchmark execution framework.

## abstract_adapter.py

Purpose:

Benchmark adapter contract.

Responsibilities:

* define benchmark execution interface
* provide extension point for solution-specific benchmark execution

---

## adapter_registry.py

Purpose:

Benchmark adapter registration.

Responsibilities:

* adapter discovery
* adapter lookup
* solution-to-adapter mapping

---

## runtime.py

Purpose:

Benchmark execution lifecycle.

Responsibilities:

* benchmark execution state management

Lifecycle:

```text
PENDING
  ↓
RUNNING
  ↓
COMPLETED

or

ABORTED
```

---

# cli/

Command processing and parameter resolution.

## prompt_resolution.py

Purpose:

Command-aware prompt resolution.

Responsibilities:

* resolve missing inputs
* merge CLI/config/environment values
* validate command requirements

---

## command_integration.py

Purpose:

CLI enforcement layer.

Responsibilities:

* integrate prompt resolution
* block execution when required parameters are unresolved

---

# data/

## generator.py

Purpose:

Synthetic data generation.

Responsibilities:

* deterministic dataset generation
* profile-driven data creation
* repeatable benchmark inputs

---

# deploy/

## deployment.py

Purpose:

Framework deployment manager.

Supported source modes:

```text
local_sync
git_branch
git_tag
git_commit
```

Responsibilities:

* deployment execution
* source resolution
* deployment orchestration

---

# diagnostics/

## analyzer.py

Purpose:

Diagnostic analysis engine.

Responsibilities:

* failure classification
* observability validation
* timeline reconstruction
* diagnostic reporting

---

# execution/

Core planning, governance, and execution framework.

---

## identity.py

Purpose:

Execution identity framework.

Responsibilities:

* run identity creation
* execution identity creation
* workspace management
* effective configuration generation

---

## planner.py

Purpose:

Execution planning.

Responsibilities:

* infrastructure planning
* suite planning
* execution planning

---

## functional_matrix.py

Purpose:

Functional validation expansion.

Responsibilities:

* expand selected UAT definitions
* create executable functional validation plans

---

## benchmark_matrix.py

Purpose:

Benchmark plan generation.

Responsibilities:

* expand benchmark definitions
* create executable benchmark plans

---

## suite_registry.py

Purpose:

Suite governance.

Responsibilities:

* suite definitions
* suite selection
* deterministic test inclusion

---

## infrastructure_registry.py

Purpose:

Infrastructure catalog.

Responsibilities:

* infrastructure definition management
* infrastructure discovery

---

## infrastructure_selection.py

Purpose:

Infrastructure selection framework.

Responsibilities:

* fixed selection
* random selection
* exhaustive selection

---

## topology_planner.py

Purpose:

Topology planning framework.

Responsibilities:

* topology signature generation
* infrastructure signature generation
* dependency mapping generation

---

## uat_catalog.py

Purpose:

UAT catalog loading and validation.

Responsibilities:

* catalog parsing
* suite mapping resolution
* topology policy resolution

---

## uat_domain.py

Purpose:

Domain validation.

Responsibilities:

* domain metadata validation
* domain-specific governance

---

## version_resolver.py

Purpose:

Version governance.

Responsibilities:

* determine current product version
* validate version registration
* resolve version metadata

---

## regression_promotion.py

Purpose:

Regression selection engine.

Responsibilities:

* regression.yml processing
* regression promotion selection
* version inheritance control

---

## iv_adoption.py

Purpose:

Legacy implementation-version adoption framework.

Responsibilities:

* historical regression adoption
* version transition support

---

## mock_alignment.py

Purpose:

Mock infrastructure alignment.

Responsibilities:

* align mock topologies with real execution topology
* depth profile alignment

---

## benchmark_config.py

Purpose:

Benchmark configuration management.

Responsibilities:

* benchmark enablement
* benchmark configuration resolution

---

## benchmark_catalog_registry.py

Purpose:

Benchmark catalog loading.

Responsibilities:

* benchmark catalog discovery
* benchmark catalog validation

---

## sla_governance.py

Purpose:

Benchmark SLA governance.

Responsibilities:

* SLA validation
* benchmark-to-SLA mapping validation

---

## solution_governance.py

Purpose:

Solution onboarding governance.

Responsibilities:

* validate solution completeness
* verify required framework registrations

---

# reports/

Reporting and aggregation framework.

---

## pytest_integration.py

Purpose:

Pytest integration framework.

Responsibilities:

* JUnit XML ingestion
* pytest result normalization
* RXTA-compatible result generation

---

## aggregation.py

Purpose:

Validation aggregation framework.

Responsibilities:

* aggregate validation results
* produce run-level summaries

---

## aggregate_command.py

Purpose:

CLI aggregation integration.

Responsibilities:

* aggregate command implementation

---

## default_summary.py

Purpose:

Default execution summary generation.

Responsibilities:

* JSON summary generation
* Markdown summary generation

---

## report.py

Purpose:

Generic reporting framework.

Responsibilities:

* report model
* report serialization
* report generation

---

## adapters/default_adapter.py

Purpose:

Default reporting adapter.

Responsibilities:

* report adapter abstraction
* default reporting implementation

---

# executor/

Legacy execution lifecycle framework.

---

## run_context.py

Purpose:

Execution context management.

Responsibilities:

* run context creation
* run metadata management

---

## lifecycle.py

Purpose:

Execution lifecycle orchestration.

Responsibilities:

* setup
* execution
* metrics collection
* reporting
* cleanup

---

# log_analyzer/

## analyzer.py

Purpose:

Observability log analysis.

Responsibilities:

* event validation
* checkpoint validation
* execution timeline reconstruction

---

# manifests/

## loader.py

Purpose:

Manifest loading and validation.

Supported manifest types:

* version manifests
* scenario manifests
* setup manifests
* UAT manifests

Responsibilities:

* manifest parsing
* schema validation

---

# metrics/

## collector.py

Purpose:

Metrics collection framework.

Responsibilities:

* execution metrics
* timing metrics
* count metrics
* run statistics

---

# Overall Assessment

RXTA v0.2.1 is a validation automation framework providing:

* deployment automation
* execution identity management
* suite governance
* infrastructure governance
* topology-aware execution planning
* functional validation planning
* benchmark planning
* benchmark runtime execution
* pytest result ingestion
* aggregation
* diagnostics
* SLA governance
* version governance
* regression governance
* solution onboarding governance

The framework architecture is largely implemented and aligns with the v0.2.1 CR set. The primary area that remains incomplete is full per-version UAT automation under the current catalog-driven UAT structure.
