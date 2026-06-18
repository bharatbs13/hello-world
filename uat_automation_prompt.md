RXTA Per-Version UAT Automation Instructions
Objective
For each Product Version (PV), automate the UAT plan and configure regression selection with minimal required changes.
The current PV is read from:
pyproject.toml
Example:
version = "0.2.1"
 
⸻
 
1. Create Version Folder
For each PV, create or update:
automation/uat/v0_2_1/
Use the normalized version folder format:
v0_2_1
v0_2_2
v0_3_0
 
⸻
 
2. Read Existing Version Examples First
Before creating new automation, inspect previous accepted UAT files.
Example:
automation/uat/v0_2_0/
Reuse existing pytest patterns, fixtures, setup, cleanup, and naming style where possible.
Do not create a new pattern if an old version already has a suitable pattern.
 
⸻
 
3. Automate Current-Version UAT Cases
Read the PV UAT Markdown plan.
Example:
docs/uat/uat_v0.2.1.md
For each UAT test case in the Markdown plan:
UAT .md test case
    ↓
catalog entry
    ↓
pytest file
    ↓
pytest function
Each automated test must:
- be runnable alone
- set up its own required state
- clean up after itself
- not depend on execution order
- not leave state that affects another test
 
⸻
 
4. Use Domain Partition Catalogs
Do not put all test cases in one generic catalog.
Use partition/domain catalogs.
For backend:
automation/uat/v0_2_1/catalogs/backend_uat_catalog.yml
Future examples:
automation/uat/v0_2_1/catalogs/api_uat_catalog.yml
automation/uat/v0_2_1/catalogs/cli_uat_catalog.yml
automation/uat/v0_2_1/catalogs/frontend_uat_catalog.yml
Partition control lives in:
automation/uat/v0_2_1/catalogs/uat_partitions.yml
Example:
partitions:
  backend:
    enabled: true
    handler: backend
    catalog: backend_uat_catalog.yml

  frontend:
    enabled: false
    handler: frontend
    catalog: frontend_uat_catalog.yml
Rules:
enabled=true + catalog exists  → include
enabled=true + catalog missing → fail
enabled=false + catalog exists → skip
enabled=false + catalog missing → OK
 
⸻
 
5. Catalog Entry Requirement
Each current-version functional UAT case must have a catalog entry.
Example:
test_id: UAT-V021-FUNC-001
title: Adapter registration succeeds
status: accepted
suites:
  - smoke
  - sanity
  - feature
solution: core_runtime
topology_required: true
topology_selection_ref: core_runtime_default
path: automation/uat/v0_2_1/backend/phase1/feature/test_adapter_registration.py
function: test_adapter_registration_succeeds
automation_status: implemented
If automation is not yet implemented:
automation_status: pending
pending_reason: "Automation not implemented yet"
 
⸻
 
6. No Per-Test DB Configuration
Do not configure database or connector directly inside each test case.
Use:
test → solution → topology policy
Topology policy is configured separately in:
automation/uat/v0_2_1/catalogs/topology_selection.yml
Example:
topology_selection:
  core_runtime:
    mode: exhaustive
    depth_policy: all
For tests that do not need topology:
topology_required: false
topology_selection_ref: none
RXTA shall use:
NO_TOPOLOGY
NO_CONNECTOR
for those cases.
 
⸻
 
7. Regression Control Lives in Current PV Folder
Each PV owns its own regression policy.
For PV v0.2.1, create:
automation/uat/v0_2_1/regression.yml
This file controls which older-version tests become regression for v0.2.1.
Example:
current_version: v0.2.1
scope: functional

sources:
  v0.2.0:
    solutions:
      core_runtime:
        enabled: true
        include:
          - "*"
        exclude: []
For future PV:
automation/uat/v0_2_2/regression.yml
Example:
current_version: v0.2.2
scope: functional

sources:
  v0.2.1:
    solutions:
      core_runtime:
        enabled: true
        include:
          - "*"

  v0.2.0:
    solutions:
      core_runtime:
        enabled: false
 
⸻
 
8. Regression Selection Rules
Regression selection is controlled only by regression.yml.
Do not use regression_eligible inside UAT catalog entries.
Selection precedence:
current PV from pyproject.toml
    ↓
current PV regression.yml
    ↓
source version enabled?
    ↓
solution enabled?
    ↓
include pattern matched?
    ↓
not excluded?
    ↓
selected for regression
Rules:
disabled solution overrides include
exclude overrides include
exclude requires reason
Wildcard support:
*                    = all tests in solution scope
UAT-V020-FUNC-*      = matching test IDs
Exact test ID        = one test
 
⸻
 
9. Functional Only in regression.yml
regression.yml controls functional regression only.
Do not include load/performance in regression.yml.
Load/performance are controlled by benchmark YAML:
benchmark_catalog.yml
sla_catalog.yml
benchmark_reporting.yml
 
⸻
 
10. Load / Performance Automation
If the UAT plan includes load/performance, configure them in benchmark catalogs.
Example:
benchmark_id: BENC-LOAD-BASELINE-001
domain: backend
solution: core_runtime
benchmark_type: load
load_model: tier_load
profile: baseline
sla_id: SLA-CORE-LOAD-BASELINE
path: automation/uat/v0_2_1/backend/phase2/load/core_runtime/test_load_baseline.py
function: test_load_baseline
Every benchmark must have an SLA.
Missing SLA must fail before runtime.
 
⸻
 
11. Validation Checklist Per PV
Before marking the PV automation complete, verify:
1. pyproject.toml version matches PV
2. version folder exists
3. UAT Markdown test cases are represented in partition catalog
4. each implemented test has path + function
5. each implemented test can run alone
6. each implemented test has setup and cleanup
7. uat_partitions.yml enables only intended domains
8. suite mapping is present
9. topology selection exists where needed
10. no per-test DB config exists
11. regression.yml exists in current PV folder
12. regression.yml references older versions correctly
13. regression.yml is functional-only
14. load/performance are only in benchmark catalogs
 
⸻
 
12. Final Principle
For every PV:
Version folder stores PV automation.
Catalogs define what exists.
regression.yml defines what old tests become regression.
Topology policy defines where solution-aware tests run.
Benchmark YAML defines load/performance.
