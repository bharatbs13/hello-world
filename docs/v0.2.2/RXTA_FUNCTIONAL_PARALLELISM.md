```
=====================================================================
CR ID:       RELIX_AUTOMATION_CR_022_FUNCTIONAL_PARALLELISM
Version:     v0.2.2
Product:     Relix Automation Test Framework
Objective:   Add worker-core parallelism for Feature & Regression suites.
Scope:       Feature, Regression
Phase:       All
=====================================================================
```


## Execution Matrix

| Dimension 1 | Dimension 2          | Dimension 3          | Dimension 4    | Dimension 5  | Dimension 6              |
|-------------|----------------------|----------------------|----------------|--------------|--------------------------|
| solution    | source_connector     | target_connector     | depth_id       | worker_cores | parallel_execution_mode  |

## New Dimensions

| Dimension               | Values                                | Introduced |
|-------------------------|---------------------------------------|------------|
| worker_cores            | cores_1, cores_2, cores_4, cores_8    | v0.2.2     |
| parallel_execution_mode | process, thread, async                | v0.2.2     |

## Field Definitions

| Field             | Type      | Description                                    |
|-------------------|-----------|------------------------------------------------|
| source_connector  | Mandatory | Authoritative source database connector        |
| target_connector  | Mandatory | Authoritative target database connector        |
| db_type           | Derived   | Display field: comma-joined source,target      |
| depth_id          | Planner   | Run-scoped D profile identifier (e.g. D1)      |

## Execution Goal

| Goal                        |
|-----------------------------|
| Functional correctness      |
| Connector compatibility     |
| Concurrency safety          |
| Mode-specific validation    |

## Report Path

| Path |
|------|
| reports/{version}/{run_mode}/{run_id}/uat_parallel/{domain}/{repo_module}/ |

## Failure Report Path

| Path |
|------|
| reports/{version}/{run_mode}/{run_id}/uat_parallel/{domain}/{repo_module}/failures/ |

## Artifacts

| Artifact                  | Format |
|---------------------------|--------|
| parallel_summary          | json   |
| parallel_summary          | md     |
| execution_details         | json   |
| failed_tests              | json   |
| failed_tests              | md     |
| junit                     | xml    |
| d_mapping                 | json   |

## Run-Level Metadata

| Metadata         | Value                        |
|------------------|------------------------------|
| run_started_at   | ISO 8601 timestamp           |
| run_finished_at  | ISO 8601 timestamp           |
| duration_ms      | Total run duration           |

## Aggregation — Parallel Summary Table

| Suite      | Domain  | Repo Module  | Solution      | Topology Shape | Depth ID | Infra Signature        | Source Connector | Target Connector | DB Type (derived) | Worker Cores | Parallel Mode | Total Tests | Passed | Failed | Skipped | Error | Consistent With 1 Core | Failed Case IDs             |
|------------|---------|--------------|---------------|----------------|----------|------------------------|------------------|------------------|--------------------|--------------|---------------|-------------|--------|--------|---------|-------|------------------------|-----------------------------|
| feature    | backend | core_runtime | core_runtime  | source_target  | D1       | postgres_to_postgres   | postgres         | postgres         | postgres           | 1            | process       | 25          | 25     | 0      | 0       | 0     | baseline               | []                          |
| feature    | backend | core_runtime | core_runtime  | source_target  | D1       | postgres_to_postgres   | postgres         | postgres         | postgres           | 4            | process       | 25          | 25     | 0      | 0       | 0     | true                   | []                          |
| regression | backend | migration    | migration     | source_target  | D2       | postgres_to_mysql      | postgres         | mysql            | postgres,mysql     | 4            | thread        | 40          | 39     | 1      | 0       | 0     | false                  | [UAT-V03-BE-R-MIG-007]      |

## Aggregation — Parallel Execution Detail Table

| Execution ID                       | Test Case ID            | Suite      | Domain  | Repo Module  | Phase   | Solution      | Topology Shape | Depth ID | Infra Signature        | Source Connector | Target Connector | Worker Cores | Parallel Mode | Status | Error Reason | Duration ms |
|------------------------------------|-------------------------|------------|---------|--------------|---------|---------------|----------------|----------|------------------------|------------------|------------------|--------------|---------------|--------|--------------|-------------|
| UAT-V02-BE-F-001:D1:cores_4:abc123 | UAT-V02-BE-F-001        | feature    | backend | core_runtime | phase2  | core_runtime  | source_target  | D1       | postgres_to_postgres   | postgres         | postgres         | 4            | process       | PASSED | —            | 300         |
| UAT-V03-BE-R-MIG-007:D2:cores_4:abc123 | UAT-V03-BE-R-MIG-007 | regression | backend | migration    | phase2  | migration     | source_target  | D2       | postgres_to_mysql      | postgres         | mysql            | 4            | thread        | FAILED | Race condition in migration runner | 890 |

## Failure Report Table

| Execution ID                       | Test Case ID            | Suite      | Domain  | Repo Module  | Solution      | Depth ID | Source Connector | Target Connector | Worker Cores | Parallel Mode | Status | Error Reason                          | Duration ms | Stack Trace |
|------------------------------------|-------------------------|------------|---------|--------------|---------------|----------|------------------|------------------|--------------|---------------|--------|----------------------------------------|-------------|-------------|
| UAT-V03-BE-R-MIG-007:D2:cores_4:abc123 | UAT-V03-BE-R-MIG-007 | regression | backend | migration    | migration     | D2       | postgres         | mysql            | 4            | thread        | FAILED | Race condition in migration runner      | 890         | [trace]     |

## Group By Dimensions

| Dimension               |
|--------------------------|
| suite                    |
| domain                   |
| repo_module              |
| solution                 |
| topology_shape           |
| depth_id                 |
| worker_cores             |
| parallel_execution_mode  |

## Metrics

| Metric                               |
|--------------------------------------|
| total_tests                          |
| passed                               |
| failed                               |
| skipped                              |
| error                                |
| failed_case_ids                      |
| error_reason                         |
| execution_duration_ms                |
| result_consistent_with_single_worker |

## Acceptance Criteria

| Criteria                                  |
|-------------------------------------------|
| ✓ Functional execution parallelism        |
| ✓ Worker-core dimension                   |
| ✓ Parallel execution mode dimension       |
| ✓ Connector compatibility retained        |
| ✓ D support retained                      |
| ✓ Backward compatible with v0.2.1         |
| ✓ Failure report layer                    |
| ✓ Status and error_reason on all records  |
| ✓ Run-level timing metadata               |
| ✓ catalog.md referenced                   |
