```
=====================================================================
CR ID:       RELIX_AUTOMATION_CR_021_BENCHMARK_MATRIX
Version:     v0.2.1
Product:     Relix Automation Test Framework
Objective:   Add multi-connector benchmarking for Load & Performance suites.
Scope:       Load, Performance
Phase:       Phase 2 only
=====================================================================
```


## Execution Matrix — Load

| Dimension 1 | Dimension 2          | Dimension 3          | Dimension 4    | Dimension 5 |
|-------------|----------------------|----------------------|----------------|-------------|
| solution    | source_connector     | target_connector     | depth_id       | tier        |

## Execution Matrix — Performance

| Dimension 1 | Dimension 2          | Dimension 3          | Dimension 4    | Dimension 5 | Dimension 6 |
|-------------|----------------------|----------------------|----------------|-------------|-------------|
| solution    | source_connector     | target_connector     | depth_id       | tier        | batch_size  |

## Field Definitions

| Field             | Type      | Description                                    |
|-------------------|-----------|------------------------------------------------|
| source_connector  | Mandatory | Authoritative source database connector        |
| target_connector  | Mandatory | Authoritative target database connector        |
| db_type           | Derived   | Display field: comma-joined source,target      |
| depth_id          | Planner   | Run-scoped D profile identifier (e.g. D1)      |

## Dimensions

| Type      | Load Dimensions                                    | Performance Dimensions                                   |
|-----------|----------------------------------------------------|----------------------------------------------------------|
| Mandatory | solution, source_connector, target_connector, tier | solution, source_connector, target_connector, tier, batch_size |
| Derived   | db_type                                            | db_type                                                  |
| Optional  | execution_strategy, infra_signature                | execution_strategy, infra_signature                      |

## Tier Reference (from catalog.md)

| Tier        | Total Rows |
|-------------|------------|
| tier_smoke  | 100        |
| tier_10k    | 10,000     |
| tier_100k   | 100,000    |
| tier_1m     | 1,000,000  |
| tier_5m     | 5,000,000  |

## Report Paths

| Scope       | Path                                                                                                                           |
|-------------|--------------------------------------------------------------------------------------------------------------------------------|
| Load        | reports/{version}/{run_mode}/{run_id}/phase2/{domain}/load/{repo_module}/{solution}/{depth_id}/{tier}/                        |
| Performance | reports/{version}/{run_mode}/{run_id}/phase2/{domain}/performance/{repo_module}/{solution}/{depth_id}/{tier}/batch_{batch_size}/ |

## Artifacts

| Level     | Artifact             | Format |
|-----------|----------------------|--------|
| Leaf      | metrics              | json   |
| Leaf      | report               | xml    |
| Aggregate | load_summary         | json   |
| Aggregate | load_summary         | md     |
| Aggregate | performance_summary  | json   |
| Aggregate | performance_summary  | md     |
| Run-Level | d_mapping            | json   |

## Run-Level Metadata

| Metadata         | Value                        |
|------------------|------------------------------|
| run_started_at   | ISO 8601 timestamp           |
| run_finished_at  | ISO 8601 timestamp           |
| duration_ms      | Total run duration           |

## Aggregation — Load Summary Table

| Solution      | Topology Shape | Depth ID | Infra Signature        | Source Connector | Target Connector | DB Type (derived) | Tier       | Total Rows | Duration ms | Rows/sec | Status | Error Reason |
|---------------|----------------|----------|------------------------|------------------|------------------|--------------------|------------|------------|-------------|----------|--------|--------------|
| core_runtime  | source_target  | D1       | postgres_to_postgres   | postgres         | postgres         | postgres           | tier_10k   | 10000      | 1220        | 8196     | PASSED | —            |
| core_runtime  | source_target  | D1       | postgres_to_postgres   | postgres         | postgres         | postgres           | tier_100k  | 100000     | 8900        | 11235    | PASSED | —            |
| migration     | source_target  | D2       | postgres_to_mysql      | postgres         | mysql            | postgres,mysql     | tier_100k  | 100000     | 14300       | 6993     | PASSED | —            |

## Aggregation — Performance Summary Table

| Solution      | Topology Shape | Depth ID | Infra Signature        | Source Connector | Target Connector | DB Type (derived) | Tier       | Batch Size | Total Rows | Duration ms | Rows/sec | P95 Batch ms | P99 Batch ms | Throughput StdDev | Status | Error Reason |
|---------------|----------------|----------|------------------------|------------------|------------------|--------------------|------------|------------|------------|-------------|----------|--------------|--------------|--------------------|--------|--------------|
| core_runtime  | source_target  | D1       | postgres_to_postgres   | postgres         | postgres         | postgres           | tier_100k  | 500        | 100000     | 9400        | 10638    | 120          | 145          | 112.4              | PASSED | —            |
| core_runtime  | source_target  | D1       | postgres_to_postgres   | postgres         | postgres         | postgres           | tier_100k  | 1000       | 100000     | 8900        | 11235    | 95           | 118          | 87.3               | PASSED | —            |
| migration     | source_target  | D2       | postgres_to_mysql      | postgres         | mysql            | postgres,mysql     | tier_100k  | 1000       | 100000     | 14300       | 6993     | 150          | 178          | 156.9              | PASSED | —            |

## Group By Dimensions — Load

| Dimension          |
|--------------------|
| solution           |
| topology_shape     |
| source_connector   |
| target_connector   |
| depth_id           |
| tier               |

## Group By Dimensions — Performance

| Dimension          |
|--------------------|
| solution           |
| topology_shape     |
| source_connector   |
| target_connector   |
| depth_id           |
| tier               |
| batch_size         |

## Metrics

| Scope       | Metric              |
|-------------|---------------------|
| Load        | total_rows          |
| Load        | duration_ms         |
| Load        | rows_per_second     |
| Performance | total_rows          |
| Performance | duration_ms         |
| Performance | rows_per_second     |
| Performance | p95_batch_ms        |
| Performance | p99_batch_ms        |
| Performance | throughput_stddev   |
| All         | status              |
| All         | error_reason        |

## Acceptance Criteria

| Criteria                                  |
|-------------------------------------------|
| ✓ Multiple connector benchmarking         |
| ✓ Solution-aware topology                 |
| ✓ Tier support with row metadata          |
| ✓ Planner-generated depth_id support      |
| ✓ Separate load/performance reports       |
| ✓ Source/target connector as authoritative|
| ✓ db_type as derived display field        |
| ✓ Topology shape in reports               |
| ✓ P95, P99, and stddev metrics collected  |
| ✓ Status and error_reason on all records  |
| ✓ Run-level timing metadata               |
| ✓ catalog.md referenced                   |
