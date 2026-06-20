CR-XXX Directory Alignment with Execution Profiles
Status
Proposed
Target Version
v0.2.3
 
⸻
 
Problem Statement
CR-025 introduces the execution profile framework and establishes:
coverage_tier
    ×
validation_type
    ×
execution_profile
as the authoritative RXTA execution model.
 
Following CR-025, execution behavior is driven by catalog metadata:
execution_profiles:
  - no_db
  - mock_db
  - real_db
However, the physical UAT directory structure continues to use legacy phase-oriented naming:
phase1/
phase2/
These directory names originated from the earlier execution model and no longer accurately represent execution semantics.
This creates terminology drift between:
* catalog contracts
* CLI contracts
* documentation
* filesystem structure
 
⸻
 
Objective
Align the UAT directory structure with the execution profile framework introduced by CR-025.
The directory structure shall communicate execution intent directly and use the same terminology as the catalog and CLI.
 
⸻
 
Current Structure
backend/
├── phase1/
│   ├── feature/
│   └── regression/
└── phase2/
    ├── feature/
    ├── regression/
    ├── load/
    └── performance/
 
⸻
 
Proposed Structure
backend/
├── mock_db/
│   ├── feature/
│   └── regression/
└── real_db/
    ├── feature/
    ├── regression/
    ├── load/
    └── performance/
 
⸻
 
Execution Semantics
mock_db
Represents tests executable without real infrastructure.
Includes:
no_db
mock_db
eligible test cases.
Examples:
* registry validation
* configuration validation
* profile validation
* mock connector execution
* in-memory execution
 
⸻
 
real_db
Represents tests requiring real infrastructure.
Examples:
* connector integration
* transport validation
* database connectivity
* benchmark execution
* end-to-end execution
 
⸻
 
Scope
Included
* directory rename
* catalog path updates
* benchmark catalog path updates
* coverage document updates
* module documentation updates
* README updates
* test discovery validation
Excluded
* execution profile logic
* catalog schema changes
* regression governance changes
* topology planning changes
* benchmark methodology changes
These capabilities remain owned by CR-025 and earlier CRs.
 
⸻
 
Backward Compatibility
Execution behavior shall remain unchanged.
The following shall remain identical before and after migration:
coverage_tier selection
validation_type selection
execution_profile filtering
topology expansion
regression promotion
benchmark execution
Only filesystem organization changes.
 
⸻
 
Migration Rules
Rule 1
Rename:
phase1 → mock_db
Rule 2
Rename:
phase2 → real_db
Rule 3
Update all catalog path references.
Examples:
Before:
automation/uat/v0_2_1/backend/phase1/feature/test_adapter.py
After:
automation/uat/v0_2_1/backend/mock_db/feature/test_adapter.py
 
⸻
 
Rule 4
Update benchmark catalog paths.
Before:
backend/phase2/load/core_runtime/
backend/phase2/performance/core_runtime/
After:
backend/real_db/load/core_runtime/
backend/real_db/performance/core_runtime/
 
⸻
 
Rule 5
Update documentation examples and diagrams.
 
⸻
 
Acceptance Criteria
AC-001
All UAT directories use execution-profile terminology.
AC-002
No remaining phase1 references exist within active UAT execution paths.
AC-003
No remaining phase2 references exist within active UAT execution paths.
AC-004
All catalog paths resolve successfully after migration.
AC-005
Benchmark catalog paths resolve successfully after migration.
AC-006
Pytest discovery succeeds after migration.
AC-007
Coverage documents are updated.
AC-008
Module documentation is updated.
AC-009
README examples are updated.
AC-010
Execution results before and after migration remain functionally equivalent.
 
⸻
 
Benefits
* terminology consistency
* reduced architectural ambiguity
* alignment between catalogs and filesystem structure
* easier onboarding for contributors
* clearer execution ownership model
 
⸻
 
Traceability
CR	Relationship
CR-025	Depends on execution profile framework
CR-020	Uses existing suite selection model
CR-018	No behavioral impact on regression governance
CR-024	Uses catalog execution profile metadata
