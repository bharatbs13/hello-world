# CR: Automated Validation Report Aggregation

**CR ID:** `RELIX_AUTOMATION_VALIDATION_REPORT_AGGREGATION`

**Target Version:** `v0.2.1`

**Product:** Relix Automation Test Framework

---

# Objective

Automatically generate human-readable validation reports from available execution artifacts.

The aggregation framework shall operate on a best-effort basis and generate release evidence even when only a subset of supported artifacts are present.

---

# Scope

Applicable to:

| Scope       | Supported |
| ----------- | --------- |
| Feature     | Yes       |
| Regression  | Yes       |
| Load        | Yes       |
| Performance | Yes       |

---

# Input Artifacts

The aggregator consumes any available execution artifacts.

| Artifact               | Source           |
| ---------------------- | ---------------- |
| report.xml             | pytest           |
| metrics.json           | load/performance |
| execution_details.json | optional         |
| d_mapping.json         | future           |
| run_metadata.json      | future           |

Missing artifacts shall not fail aggregation.

Unknown artifacts shall be ignored.

Unknown artifacts shall not affect aggregation status.

---

# Run Metadata

Every generated report shall include:

| Field              |
| ------------------ |
| version            |
| run_mode           |
| run_id             |
| generated_at       |
| aggregation_status |

Run metadata shall be included in both markdown and JSON outputs.

---

# Aggregation Status

| Status   | Meaning                                                                      |
| -------- | ---------------------------------------------------------------------------- |
| COMPLETE | All discovered supported artifacts processed successfully                    |
| PARTIAL  | One or more supported artifacts are missing for a discovered execution scope |
| EMPTY    | No supported artifacts discovered                                            |
| ERROR    | Aggregation execution failed                                                 |

Examples:

| Scenario                                                        | Status   |
| --------------------------------------------------------------- | -------- |
| Feature execution with valid report.xml present                 | COMPLETE |
| Load execution with report.xml present and metrics.json missing | PARTIAL  |
| No supported artifacts discovered                               | EMPTY    |
| Aggregation terminated due to execution failure                 | ERROR    |

Aggregation status shall be recorded in all generated markdown and JSON outputs.

---

# Functional Aggregation

Applies to:

```text
feature
```

---

## Output

Generated files:

```text
feature_validation.md
feature_validation.json
```

Markdown files are intended for release evidence and human review.

JSON files are intended for machine-readable consumption, dashboards, automation, and future comparison workflows.

---

## Functional Summary Table

One row per execution dimension set.

| Phase | Domain | Repo Module | Solution | DB Type | Topology Shape | Depth ID | Total Tests | Passed | Failed | Error | Failed Case IDs |
| ----- | ------ | ----------- | -------- | ------- | -------------- | -------- | ----------- | ------ | ------ | ----- | --------------- |

Example:

| phase2 | backend | core_runtime | core_runtime | postgres | source_target | D1 | 25 | 25 | 0 | 0 | [] |

---

## Functional Metrics

Only summary statistics shall be included.

| Metric          |
| --------------- |
| total_tests     |
| passed          |
| failed          |
| error           |
| failed_case_ids |

Per-test details shall not be included in markdown reports.

---

# Regression Aggregation

Applies to:

```text
regression
```

Regression aggregation follows the same structure, dimensions, metrics, output formats, metadata requirements, aggregation status rules, and aggregation behavior defined for Functional Aggregation.

Feature and Regression reports shall be generated independently.

Aggregation logic may be shared internally; however, output artifacts shall remain separate and shall not be combined into a single report.

---

## Output

Generated files:

```text
regression_validation.md
regression_validation.json
```

---

# Load Aggregation

Applies to:

```text
load
```

---

## Output

Generated files:

```text
load_validation.md
load_validation.json
```

---

## Load Summary Table

One row per execution dimension set.

| Phase | Domain | Repo Module | Solution | DB Type | Topology Shape | Depth ID | Tier | Total Rows | Duration ms | Rows/sec | Status |
| ----- | ------ | ----------- | -------- | ------- | -------------- | -------- | ---- | ---------- | ----------- | -------- | ------ |

---

## Load Metrics

Only execution metrics shall be included.

| Metric          |
| --------------- |
| total_rows      |
| duration_ms     |
| rows_per_second |
| batch_size      |
| status          |

---

# Performance Aggregation

Applies to:

```text
performance
```

---

## Output

Generated files:

```text
performance_validation.md
performance_validation.json
```

---

## Performance Summary Table

One row per execution dimension set.

| Phase | Domain | Repo Module | Solution | DB Type | Topology Shape | Depth ID | Tier | Batch Size | Duration ms | Avg Batch ms | Rows/sec | Status |
| ----- | ------ | ----------- | -------- | ------- | -------------- | -------- | ---- | ---------- | ----------- | ------------ | -------- | ------ |

---

## Performance Metrics

Only execution metrics shall be included.

| Metric          |
| --------------- |
| duration_ms     |
| avg_batch_ms    |
| rows_per_second |
| batch_size      |
| status          |

---

# Aggregation Dimensions

The aggregator shall render all dimensions discovered in available metadata.

Unknown dimensions shall be appended automatically to summary tables where applicable.

Examples:

## v0.2.0

| Dimension   |
| ----------- |
| phase       |
| domain      |
| repo_module |
| solution    |

## v0.2.1

| Dimension      |
| -------------- |
| db_type        |
| topology_shape |
| depth_id       |
| tier           |

## v0.2.2

| Dimension               |
| ----------------------- |
| worker_cores            |
| parallel_execution_mode |
| vm_profile              |

These examples are illustrative only and shall not restrict future dimension expansion.

---

# Output Location

Release evidence shall be stored under:

```text
validation/
└── releases/
    └── <version>/
        ├── feature_validation.md
        ├── feature_validation.json
        ├── regression_validation.md
        ├── regression_validation.json
        ├── load_validation.md
        ├── load_validation.json
        ├── performance_validation.md
        └── performance_validation.json
```

Examples:

```text
validation/releases/v0.2.0/
validation/releases/v0.2.1/
validation/releases/v0.2.2/
```

---

# Acceptance Criteria

| Criteria                                              |
| ----------------------------------------------------- |
| Generate markdown automatically                       |
| Generate JSON automatically                           |
| Best-effort aggregation                               |
| Missing artifacts do not fail aggregation             |
| Unknown artifacts do not affect aggregation status    |
| Separate reports per test scope                       |
| Functional reports contain only validation statistics |
| Regression reports contain only validation statistics |
| Load reports contain execution metrics                |
| Performance reports contain execution metrics         |
| Automatically expands when new dimensions appear      |
| Suitable for release evidence storage                 |
| Suitable for machine-readable consumption             |

---

# Status

```text
Status: APPROVED
Priority: High
Target Version: v0.2.1
Category: Reporting
Implementation Risk: Low
Backward Compatibility Risk: None
Ready for Development: YES
CR State: FROZEN
```
