=====================================================================
CR ID:       RELIX_AUTOMATION_CR_021_FUNCTIONAL_CONNECTOR_MATRIX
Version:     v0.2.1
Product:     Relix Automation Test Framework
Objective:   Add multi-connector functional testing for Feature & Regression suites.
Scope:       Feature, Regression
Phase:       All
=====================================================================

## Execution Matrix

| Dimension 1 | Dimension 2          | Dimension 3          | Dimension 4    |
|-------------|----------------------|----------------------|----------------|
| solution    | source_connector     | target_connector     | depth_id       |

## Field Definitions

| Field             | Type      | Description                                    |
|-------------------|-----------|------------------------------------------------|
| source_connector  | Mandatory | Authoritative source database connector        |
| target_connector  | Mandatory | Authoritative target database connector        |
| db_type           | Derived   | Display field: comma-joined source,target      |
| depth_id          | Planner   | Run-scoped D profile identifier (e.g. D1)      |

Note: `depth_profile` and `depth_mode` are deprecated. Use only `depth_id`, `topology_shape`, and `infra_signature`.

## Dimensions

| Type      | Dimensions                                                                 |
|-----------|----------------------------------------------------------------------------|
| Mandatory | solution, source_connector, target_connector, test_case_id, execution_id   |
| Derived   | db_type (from source_connector + target_connector)                         |
| Optional  | infra_signature, execution_strategy                                        |

## Report Path

| Path |
|------|
| reports/{version}/{run_mode}/{run_id}/uat/{domain}/{repo_module}/ |

## Failure Report Path

| Path |
|------|
| reports/{version}/{run_mode}/{run_id}/uat/{domain}/{repo_module}/failures/ |

## Artifacts

| Artifact              | Format |
|-----------------------|--------|
| uat_summary           | json   |
| uat_summary           | md     |
| execution_details     | json   |
| failed_tests          | json   |
| failed_tests          | md     |
| junit                 | xml    |
| d_mapping             | json   |

## Run-Level Metadata

| Metadata         | Value                        |
|------------------|------------------------------|
| run_started_at   | ISO 8601 timestamp           |
| run_finished_at  | ISO 8601 timestamp           |
| duration_ms      | Total run duration           |

## Aggregation — Summary Table

| Suite      | Domain  | Repo Module  | Solution      | Topology Shape | Depth ID | Infra Signature        | Source Connector | Target Connector | DB Type (derived) | Execution Strategy | Total Tests | Passed | Failed | Skipped | Error | Failed Case IDs        |
|------------|---------|--------------|---------------|----------------|----------|------------------------|------------------|------------------|--------------------|--------------------|-------------|--------|--------|---------|-------|------------------------|
| feature    | backend | core_runtime | core_runtime  | source_target  | D1       | postgres_to_postgres   | postgres         | postgres         | postgres           | exhaustive         | 25          | 25     | 0      | 0       | 0     | []                     |
| regression | backend | core_runtime | core_runtime  | source_target  | D1       | postgres_to_postgres   | postgres         | postgres         | postgres           | exhaustive         | 40          | 39     | 1      | 0       | 0     | [UAT-V02-BE-R-004]     |
| feature    | backend | migration    | migration     | source_target  | D2       | postgres_to_mysql      | postgres         | mysql            | postgres,mysql     | smoke              | 18          | 17     | 1      | 0       | 0     | [UAT-V03-BE-F-MIG-002] |

## Aggregation — Execution Detail Table

| Execution ID                | Test Case ID          | Suite      | Domain  | Repo Module  | Phase   | Solution      | Topology Shape | Depth ID | Infra Signature        | Source Connector | Target Connector | Status | Error Reason | Duration ms |
|-----------------------------|-----------------------|------------|---------|--------------|---------|---------------|----------------|----------|------------------------|------------------|------------------|--------|--------------|-------------|
| UAT-V02-BE-F-001:D1:abc123  | UAT-V02-BE-F-001      | feature    | backend | core_runtime | phase2  | core_runtime  | source_target  | D1       | postgres_to_postgres   | postgres         | postgres         | PASSED | —            | 712         |
| UAT-V03-BE-F-MIG-002:D2:abc123 | UAT-V03-BE-F-MIG-002 | feature    | backend | migration    | phase2  | migration     | source_target  | D2       | postgres_to_mysql      | postgres         | mysql            | FAILED | AssertionError: row count mismatch | 1120 |

## Failure Report Table

| Execution ID                | Test Case ID          | Suite      | Domain  | Repo Module  | Solution      | Depth ID | Source Connector | Target Connector | Status | Error Reason                    | Duration ms | Stack Trace |
|-----------------------------|-----------------------|------------|---------|--------------|---------------|----------|------------------|------------------|--------|----------------------------------|-------------|-------------|
| UAT-V03-BE-F-MIG-002:D2:abc123 | UAT-V03-BE-F-MIG-002 | feature    | backend | migration    | migration     | D2       | postgres         | mysql            | FAILED | AssertionError: row count mismatch | 1120        | [trace]     |

## Group By Dimensions

| Dimension          |
|--------------------|
| suite              |
| domain             |
| repo_module        |
| solution           |
| topology_shape     |
| depth_id           |

## Metrics

| Metric          |
|-----------------|
| total_tests     |
| passed          |
| failed          |
| skipped         |
| error           |
| failed_case_ids |
| error_reason    |

## Acceptance Criteria

| Criteria                                  |
|-------------------------------------------|
| ✓ Multiple connector support              |
| ✓ Solution-aware topology                 |
| ✓ Planner-generated depth_id support      |
| ✓ No solution-specific logic in automation|
| ✓ Source/target connector as authoritative|
| ✓ db_type as derived display field        |
| ✓ Topology shape in reports               |
| ✓ Execution strategy in reports           |
| ✓ Failure report layer                    |
| ✓ Status and error_reason on all records  |
| ✓ Run-level timing metadata               |
| ✓ catalog.md referenced                   |
