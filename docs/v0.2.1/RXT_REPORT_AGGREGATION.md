# CR: Best-Effort Report Aggregation by Test Scope

## CR ID

`RELIX_AUTOMATION_BASIC_REPORT_AGGREGATION`

## Target Version

`v0.2.1`

## Product

Relix Automation Test Framework

## Objective

Add best-effort aggregation over available report artifacts for:

```text
functional tests
load tests
performance tests
````

Aggregation must not fail the run if some artifacts are missing. It should collect whatever exists and clearly report missing artifacts.

---

## Scope

| Test Scope  | Includes             |
| ----------- | -------------------- |
| Functional  | feature + regression |
| Load        | load                 |
| Performance | performance          |

---

## Non-Goal

This CR does not add:

```text
parallelism aggregation
connector-matrix execution
D-profile generation
SLA enforcement
```

Those remain separate CRs.

---

## Aggregation Principle

Aggregation is best-effort.

| Condition          | Behavior                          |
| ------------------ | --------------------------------- |
| artifact exists    | parse and include                 |
| artifact missing   | record as missing                 |
| artifact malformed | record parse error                |
| partial run        | aggregate available results       |
| failed run         | still aggregate available results |

---

## Report Root

```text
reports/{version}/{run_mode}/{run_id}/
```

---

## Output Artifacts

```text
reports/{version}/{run_mode}/{run_id}/
├── run_metadata.json
├── combined_summary.json
├── combined_summary.md
├── functional_summary.json
├── functional_summary.md
├── load_summary.json
├── load_summary.md
├── performance_summary.json
└── performance_summary.md
```

---

# 1. Functional Aggregation

Functional aggregation covers:

```text
feature
regression
```

## Input Artifacts

```text
phase*/{domain}/feature/report.xml
phase*/{domain}/regression/report.xml
```

## Functional Dimensions

| Dimension       | Required | Notes                          |
| --------------- | -------- | ------------------------------ |
| phase           | yes      | phase1, phase2                 |
| suite           | yes      | feature, regression            |
| domain          | yes      | backend now, frontend later    |
| repo_module     | optional | derive from path if available  |
| solution        | optional | v0.2.1+                        |
| db_type         | optional | mock/postgres/etc.             |
| depth_id        | optional | D1, D2, etc.                   |
| infra_signature | optional | postgres_to_postgres           |
| test_case_id    | yes      | from junit testcase            |
| execution_id    | optional | if available                   |
| status          | yes      | PASSED, FAILED, SKIPPED, ERROR |
| error_reason    | optional | from junit failure/error       |

## Functional Summary Group By

| Dimension   |
| ----------- |
| phase       |
| suite       |
| domain      |
| repo_module |
| solution    |
| db_type     |
| depth_id    |

## Functional Summary Metrics

| Metric            |
| ----------------- |
| total_tests       |
| passed            |
| failed            |
| skipped           |
| error             |
| failed_case_ids   |
| error_case_ids    |
| missing_artifacts |
| parse_errors      |

## Functional Summary Table

| Phase  | Suite   | Domain  | Repo Module  | Solution     | DB Type  | Depth ID | Total Tests | Passed | Failed | Skipped | Error | Failed Case IDs |
| ------ | ------- | ------- | ------------ | ------------ | -------- | -------- | ----------: | -----: | -----: | ------: | ----: | --------------- |
| phase1 | feature | backend | core_runtime | core_runtime | mock     | D0       |          14 |     14 |      0 |       0 |     0 | []              |
| phase2 | feature | backend | core_runtime | core_runtime | postgres | D1       |           5 |      5 |      0 |       0 |     0 | []              |

---

# 2. Load Aggregation

Load aggregation covers:

```text
load
```

## Input Artifacts

```text
phase2/{domain}/load/{repo_module}/metrics.json
phase2/{domain}/load/{repo_module}/report.xml
```

Future-compatible path:

```text
phase2/{domain}/load/{repo_module}/{solution}/{depth_id}/{tier}/metrics.json
```

## Load Dimensions

| Dimension       | Required | Notes                         |
| --------------- | -------- | ----------------------------- |
| phase           | yes      | always phase2                 |
| suite           | yes      | load                          |
| domain          | yes      | backend now                   |
| repo_module     | yes      | core_runtime now              |
| solution        | optional | core_runtime now              |
| db_type         | optional | postgres/etc.                 |
| depth_id        | optional | D1/etc.                       |
| infra_signature | optional | postgres_to_postgres          |
| tier            | optional | tier_smoke/tier_10k/etc.      |
| batch_size      | optional | current v0.2.0 has batch_size |
| status          | yes      | from metrics/report           |

## Load Summary Group By

| Dimension   |
| ----------- |
| phase       |
| domain      |
| repo_module |
| solution    |
| db_type     |
| depth_id    |
| tier        |
| batch_size  |

## Load Summary Metrics

| Metric            |
| ----------------- |
| total_rows        |
| duration_ms       |
| rows_per_second   |
| batch_size        |
| tables_completed  |
| status            |
| missing_artifacts |
| parse_errors      |

## Load Summary Table

| Phase  | Domain  | Repo Module  | Solution     | DB Type  | Depth ID | Tier       | Batch Size | Total Rows | Duration ms | Rows/sec | Status |
| ------ | ------- | ------------ | ------------ | -------- | -------- | ---------- | ---------: | ---------: | ----------: | -------: | ------ |
| phase2 | backend | core_runtime | core_runtime | postgres | D1       | tier_smoke |         25 |        100 |      188.05 |   531.79 | PASSED |

---

# 3. Performance Aggregation

Performance aggregation covers:

```text
performance
```

## Input Artifacts

```text
phase2/{domain}/performance/{repo_module}/metrics.json
phase2/{domain}/performance/{repo_module}/report.xml
```

Future-compatible path:

```text
phase2/{domain}/performance/{repo_module}/{solution}/{depth_id}/{tier}/batch_{batch_size}/metrics.json
```

## Performance Dimensions

| Dimension       | Required | Notes                      |
| --------------- | -------- | -------------------------- |
| phase           | yes      | always phase2              |
| suite           | yes      | performance                |
| domain          | yes      | backend now                |
| repo_module     | yes      | core_runtime now           |
| solution        | optional | core_runtime now           |
| db_type         | optional | postgres/etc.              |
| depth_id        | optional | D1/etc.                    |
| infra_signature | optional | postgres_to_postgres       |
| tier            | optional | tier_smoke/tier_10k/etc.   |
| batch_size      | yes      | from batch_results or path |
| test_type       | optional | batch_latency              |
| status          | yes      | from metrics/report        |

## Performance Summary Group By

| Dimension   |
| ----------- |
| phase       |
| domain      |
| repo_module |
| solution    |
| db_type     |
| depth_id    |
| tier        |
| batch_size  |
| test_type   |

## Performance Summary Metrics

| Metric            |
| ----------------- |
| source_rows       |
| total_rows        |
| batches           |
| duration_ms       |
| avg_batch_ms      |
| rows_per_second   |
| p95_batch_ms      |
| p99_batch_ms      |
| throughput_stddev |
| status            |
| missing_artifacts |
| parse_errors      |

## Performance Summary Table

| Phase  | Domain  | Repo Module  | Solution     | DB Type  | Depth ID | Tier       | Test Type     | Batch Size | Total Rows | Batches | Duration ms | Avg Batch ms | Rows/sec | Status |
| ------ | ------- | ------------ | ------------ | -------- | -------- | ---------- | ------------- | ---------: | ---------: | ------: | ----------: | -----------: | -------: | ------ |
| phase2 | backend | core_runtime | core_runtime | postgres | D1       | tier_smoke | batch_latency |         10 |        100 |      10 |      181.48 |        18.15 |   551.01 | PASSED |
| phase2 | backend | core_runtime | core_runtime | postgres | D1       | tier_smoke | batch_latency |         25 |        100 |       4 |       65.01 |        16.25 |  1538.26 | PASSED |
| phase2 | backend | core_runtime | core_runtime | postgres | D1       | tier_smoke | batch_latency |         50 |        100 |       2 |       49.10 |        24.55 |  2036.81 | PASSED |

---

# 4. Combined Summary

## combined_summary.json

Should include:

| Section           |
| ----------------- |
| run               |
| functional        |
| load              |
| performance       |
| artifacts         |
| missing_artifacts |
| parse_errors      |

## Run-Level Fields

| Field        |
| ------------ |
| version      |
| run_mode     |
| run_id       |
| phase        |
| suite        |
| status       |
| started_at   |
| completed_at |
| duration_ms  |

## Combined Summary Table

| Scope       | Total | Passed | Failed | Skipped | Error | Missing Artifacts | Parse Errors |
| ----------- | ----: | -----: | -----: | ------: | ----: | ----------------: | -----------: |
| functional  |    19 |     19 |      0 |       0 |     0 |                 0 |            0 |
| load        |     1 |      1 |      0 |       0 |     0 |                 0 |            0 |
| performance |     3 |      3 |      0 |       0 |     0 |                 0 |            0 |

---

# 5. Best-Effort Rules

| Case                   | Required Behavior                                   |
| ---------------------- | --------------------------------------------------- |
| no functional reports  | functional summary exists with zero rows            |
| no load metrics        | load summary exists with missing_artifacts entry    |
| malformed metrics.json | parse_errors entry added                            |
| failed pytest XML      | failed/error counts parsed                          |
| partial phase run      | only available phase artifacts aggregated           |
| phase1 only            | load/performance summaries empty                    |
| phase2 only            | functional/load/performance aggregated if available |
| all phase run          | all available artifacts aggregated                  |

---

# 6. Backward Compatibility

Aggregator must support v0.2.0 raw artifact layout:

```text
phase1/backend/feature/report.xml
phase2/backend/feature/report.xml
phase2/backend/load/core_runtime/metrics.json
phase2/backend/performance/core_runtime/metrics.json
```

Aggregator must also support v0.2.1+ catalog layout:

```text
phase2/backend/load/{repo_module}/{solution}/{depth_id}/{tier}/metrics.json
phase2/backend/performance/{repo_module}/{solution}/{depth_id}/{tier}/batch_{batch_size}/metrics.json
```

---

# 7. Acceptance Criteria

| Criteria                                  |
| ----------------------------------------- |
| Aggregation is best-effort                |
| Aggregation never fails the test run      |
| Functional summary generated              |
| Load summary generated                    |
| Performance summary generated             |
| Combined summary generated                |
| Missing artifacts are explicitly recorded |
| Parse errors are explicitly recorded      |
| v0.2.0 raw report layout supported        |
| v0.2.1 catalog layout supported           |
| Group-by dimensions are scope-specific    |
| Markdown and JSON summaries generated     |

