```
=====================================================================
CR ID:       RELIX_AUTOMATION_CR_022_BENCHMARK_PARALLELISM
Version:     v0.2.2
Product:     Relix Automation Test Framework
Objective:   Add parallelism benchmarking for Load & Performance suites.
Scope:       Load, Performance
Phase:       Phase 2 only
=====================================================================
```


## Execution Matrix — Load

| Dimension 1 | Dimension 2          | Dimension 3          | Dimension 4    | Dimension 5 | Dimension 6  | Dimension 7              |
|-------------|----------------------|----------------------|----------------|-------------|--------------|--------------------------|
| solution    | source_connector     | target_connector     | depth_id       | tier        | worker_cores | parallel_execution_mode  |

## Execution Matrix — Performance

| Dimension 1 | Dimension 2          | Dimension 3          | Dimension 4    | Dimension 5 | Dimension 6 | Dimension 7  | Dimension 8              |
|-------------|----------------------|----------------------|----------------|-------------|-------------|--------------|--------------------------|
| solution    | source_connector     | target_connector     | depth_id       | tier        | batch_size  | worker_cores | parallel_execution_mode  |

## New Dimensions

| Dimension               | Values                                          | Source        | Introduced |
|-------------------------|-------------------------------------------------|---------------|------------|
| worker_cores            | cores_1, cores_2, cores_4, cores_8, cores_16    | Requested     | v0.2.2     |
| parallel_execution_mode | process, thread, async                          | Requested     | v0.2.2     |
| vm_profile              | e2-standard-4, e2-standard-8, e2-standard-16    | Mapped        | v0.2.2     |

## Field Definitions

| Field             | Type      | Description                                    |
|-------------------|-----------|------------------------------------------------|
| source_connector  | Mandatory | Authoritative source database connector        |
| target_connector  | Mandatory | Authoritative target database connector        |
| db_type           | Derived   | Display field: comma-joined source,target      |
| depth_id          | Planner   | Run-scoped D profile identifier (e.g. D1)      |

## Runtime Discovery & Metadata

| Attribute          | Source         | Stored As          | Aggregation Dimension |
|--------------------|----------------|--------------------|-----------------------|
| vCPU count         | Environment    | detected_vcpu      | No (leaf metadata)    |
| Memory GB          | Environment    | detected_memory_gb | No (leaf metadata)    |
| VM identity (IP)   | Environment    | relix_vm_ip        | No (leaf metadata)    |
| VM profile         | Mapped from VM | vm_profile         | Yes                   |

## VM Profile Reference (from catalog.md)

| vm_profile       | vCPU | Memory GB |
|------------------|------|-----------|
| e2-standard-4    | 4    | 16        |
| e2-standard-8    | 8    | 32        |
| e2-standard-16   | 16   | 64        |

## Report Paths

| Scope       | Path                                                                                                                                              |
|-------------|---------------------------------------------------------------------------------------------------------------------------------------------------|
| Load        | reports/{version}/{run_mode}/{run_id}/phase2/{domain}/load/{repo_module}/{solution}/{depth_id}/{tier}/cores_{worker_cores}/                       |
| Performance | reports/{version}/{run_mode}/{run_id}/phase2/{domain}/performance/{repo_module}/{solution}/{depth_id}/{tier}/batch_{batch_size}/cores_{worker_cores}/ |

## Artifacts

| Level     | Artifact                     | Format |
|-----------|------------------------------|--------|
| Leaf      | metrics                      | json   |
| Leaf      | report                       | xml    |
| Aggregate | load_parallel_summary        | json   |
| Aggregate | load_parallel_summary        | md     |
| Aggregate | performance_parallel_summary | json   |
| Aggregate | performance_parallel_summary | md     |
| Run-Level | d_mapping                    | json   |
| Run-Level | load_comparison              | json   |
| Run-Level | load_comparison              | md     |
| Run-Level | performance_comparison       | json   |
| Run-Level | performance_comparison       | md     |

## Run-Level Metadata

| Metadata         | Value                        |
|------------------|------------------------------|
| run_started_at   | ISO 8601 timestamp           |
| run_finished_at  | ISO 8601 timestamp           |
| duration_ms      | Total run duration           |

## Leaf Metadata (per metrics.json)

| Metadata         | Description              |
|------------------|--------------------------|
| relix_vm_ip      | VM IP address            |
| detected_vcpu    | Detected vCPU count      |
| detected_memory_gb | Detected memory in GB  |

## Aggregation — Parallel Load Summary Table

| Solution      | Topology Shape | Depth ID | Infra Signature        | Source Connector | Target Connector | DB Type (derived) | Tier       | Worker Cores | Parallel Mode | vm_profile      | Total Rows | Duration ms | Rows/sec | Speedup vs 1 Core | Efficiency % | Status | Error Reason |
|---------------|----------------|----------|------------------------|------------------|------------------|--------------------|------------|--------------|---------------|-----------------|------------|-------------|----------|--------------------|--------------|--------|--------------|
| core_runtime  | source_target  | D1       | postgres_to_postgres   | postgres         | postgres         | postgres           | tier_100k  | 1            | process       | e2-standard-4   | 100000     | 12000       | 8333     | 1.00               | 100.0        | PASSED | —            |
| core_runtime  | source_target  | D1       | postgres_to_postgres   | postgres         | postgres         | postgres           | tier_100k  | 2            | process       | e2-standard-4   | 100000     | 7800        | 12820    | 1.54               | 77.0         | PASSED | —            |
| core_runtime  | source_target  | D1       | postgres_to_postgres   | postgres         | postgres         | postgres           | tier_100k  | 4            | process       | e2-standard-4   | 100000     | 6100        | 16393    | 1.97               | 49.3         | PASSED | —            |

## Aggregation — Parallel Performance Summary Table

| Solution      | Topology Shape | Depth ID | Infra Signature        | Source Connector | Target Connector | DB Type (derived) | Tier       | Batch Size | Worker Cores | Parallel Mode | vm_profile      | Total Rows | Duration ms | Rows/sec | P95 Batch ms | P99 Batch ms | Throughput StdDev | Speedup vs 1 Core | Efficiency % | Status | Error Reason |
|---------------|----------------|----------|------------------------|------------------|------------------|--------------------|------------|------------|--------------|---------------|-----------------|------------|-------------|----------|--------------|--------------|--------------------|--------------------|--------------|--------|--------------|
| core_runtime  | source_target  | D1       | postgres_to_postgres   | postgres         | postgres         | postgres           | tier_100k  | 1000       | 1            | process       | e2-standard-4   | 100000     | 12000       | 8333     | 140          | 168          | 95.2               | 1.00               | 100.0        | PASSED | —            |
| core_runtime  | source_target  | D1       | postgres_to_postgres   | postgres         | postgres         | postgres           | tier_100k  | 1000       | 2            | process       | e2-standard-4   | 100000     | 7800        | 12820    | 110          | 135          | 78.4               | 1.54               | 77.0         | PASSED | —            |
| core_runtime  | source_target  | D1       | postgres_to_postgres   | postgres         | postgres         | postgres           | tier_100k  | 1000       | 4            | process       | e2-standard-4   | 100000     | 6100        | 16393    | 95           | 120          | 62.7               | 1.97               | 49.3         | PASSED | —            |

## Group By Dimensions — Load

| Dimension               |
|--------------------------|
| solution                 |
| topology_shape           |
| source_connector         |
| target_connector         |
| depth_id                 |
| tier                     |
| worker_cores             |
| parallel_execution_mode  |
| vm_profile               |

## Group By Dimensions — Performance

| Dimension               |
|--------------------------|
| solution                 |
| topology_shape           |
| source_connector         |
| target_connector         |
| depth_id                 |
| tier                     |
| batch_size               |
| worker_cores             |
| parallel_execution_mode  |
| vm_profile               |

## Metrics

| Scope       | Metric                |
|-------------|-----------------------|
| Both        | total_rows            |
| Both        | duration_ms           |
| Both        | rows_per_second       |
| Both        | worker_cores          |
| Both        | vm_profile            |
| Both        | speedup_vs_single_core|
| Both        | efficiency_percentage |
| Both        | status                |
| Both        | error_reason          |
| Performance | p95_batch_ms          |
| Performance | p99_batch_ms          |
| Performance | throughput_stddev     |

## Comparison Report

| Artifact                  | Path                                                                                      |
|---------------------------|-------------------------------------------------------------------------------------------|
| load_comparison           | reports/{version}/{run_mode}/{run_id}/comparison/load_comparison.json                     |
| load_comparison           | reports/{version}/{run_mode}/{run_id}/comparison/load_comparison.md                       |
| performance_comparison    | reports/{version}/{run_mode}/{run_id}/comparison/performance_comparison.json              |
| performance_comparison    | reports/{version}/{run_mode}/{run_id}/comparison/performance_comparison.md                |

### Comparison Dimensions

| Dimension               |
|--------------------------|
| solution                 |
| tier                     |
| worker_cores             |
| depth_id                 |
| vm_profile               |
| parallel_execution_mode  |
| batch_size               |

### Comparison Questions Answered

| Question                                    |
|---------------------------------------------|
| Which connector was fastest?                |
| Which topology shape was fastest?           |
| Which worker count was optimal?             |
| Which vm_profile gave best efficiency?      |
| Which parallel_mode scaled best?            |
| Which batch_size performed best?            |

## Acceptance Criteria

| Criteria                                  |
|-------------------------------------------|
| ✓ Parallel load benchmarking              |
| ✓ Parallel performance benchmarking       |
| ✓ Worker-core dimension                   |
| ✓ Parallel execution mode dimension       |
| ✓ vm_profile as aggregation dimension     |
| ✓ relix_vm_ip as leaf metadata only       |
| ✓ VM-aware metrics as leaf metadata       |
| ✓ Tier support retained                   |
| ✓ D support retained                      |
| ✓ P95, P99, stddev metrics                |
| ✓ Comparison reports with full dimensions |
| ✓ Status and error_reason on all records  |
| ✓ Run-level timing metadata               |
| ✓ Separate benchmark reports              |
| ✓ catalog.md referenced                   |
