# CR: Automated Validation Report Aggregation

**CR ID:** `RELIX_AUTOMATION_REPORT_AGGREGATION`

**Target Version:** `v0.2.1`

**Product:** Relix Automation Test Framework

---

## Objective

Automatically generate human-readable validation reports from available execution artifacts.

The aggregation framework shall operate on a best-effort basis and generate release evidence even when only a subset of expected artifacts are present.

---

## Scope

Applicable to:

| Scope       | Supported |
| ----------- | --------- |
| Feature     | Yes       |
| Regression  | Yes       |
| Load        | Yes       |
| Performance | Yes       |

---

## Input Artifacts

Aggregator consumes any available artifacts.

| Artifact               | Source           |
| ---------------------- | ---------------- |
| report.xml             | pytest           |
| metrics.json           | load/performance |
| execution_details.json | optional         |
| d_mapping.json         | future           |
| run_metadata.json      | future           |

Missing artifacts shall not fail aggregation.

---

# Functional Aggregation

Applies to:

```text
feature
regression
```

---

## Output

Generated files:

```text
feature_validation.md
regression_validation.md
```

---

## Functional Summary Table

One row per execution dimension set.

| Phase | Domain | Repo Module | Solution | DB Type | Topology Shape | Depth ID | Total Tests | Passed | Failed | Error | Failed Case IDs |
| ----- | ------ | ----------- | -------- | ------- | -------------- | -------- | ----------- | ------ | ------ | ----- | --------------- |

Example:

| phase2 | backend | core_runtime | core_runtime | postgres | source_target | D1 | 25 | 25 | 0 | 0 | [] |

---

## Functional Metrics

Only summary statistics:

| Metric          |
| --------------- |
| total_tests     |
| passed          |
| failed          |
| error           |
| failed_case_ids |

No per-test detail included in markdown.

---

# Load Aggregation

Applies to:

```text
load
```

---

## Output

Generated file:

```text
load_validation.md
```

---

## Load Summary Table

One row per execution dimension set.

| Phase | Domain | Repo Module | Solution | DB Type | Topology Shape | Depth ID | Tier | Total Rows | Duration ms | Rows/sec | Status |
| ----- | ------ | ----------- | -------- | ------- | -------------- | -------- | ---- | ---------- | ----------- | -------- | ------ |

---

## Load Metrics

Only execution metrics:

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

Generated file:

```text
performance_validation.md
```

---

## Performance Summary Table

One row per execution dimension set.

| Phase | Domain | Repo Module | Solution | DB Type | Topology Shape | Depth ID | Tier | Batch Size | Duration ms | Avg Batch ms | Rows/sec | Status |
| ----- | ------ | ----------- | -------- | ------- | -------------- | -------- | ---- | ---------- | ----------- | ------------ | -------- | ------ |

---

## Performance Metrics

Only execution metrics:

| Metric          |
| --------------- |
| duration_ms     |
| avg_batch_ms    |
| rows_per_second |
| batch_size      |
| status          |

---

# Aggregation Dimensions

The aggregator shall automatically include any dimensions available for the running version.

### v0.2.0

| Dimension   |
| ----------- |
| phase       |
| domain      |
| repo_module |
| solution    |

### v0.2.1

Adds:

| Dimension      |
| -------------- |
| db_type        |
| topology_shape |
| depth_id       |
| tier           |

### v0.2.2

Adds:

| Dimension               |
| ----------------------- |
| worker_cores            |
| parallel_execution_mode |
| vm_profile              |

The aggregator must not hardcode dimensions by version. It should render any dimensions present in metadata.

---

# Output Location

For release evidence:

```text
validation/
└── releases/
    └── v0.2.0/
        ├── feature_validation.md
        ├── regression_validation.md
        ├── load_validation.md
        └── performance_validation.md
```

For future releases:

```text
validation/
└── releases/
    └── v0.2.1/
    └── v0.2.2/
```

---

# Acceptance Criteria

| Criteria                                              |
| ----------------------------------------------------- |
| Generate markdown automatically                       |
| Best-effort aggregation                               |
| Missing artifacts do not fail aggregation             |
| Separate reports per test scope                       |
| Functional reports contain only validation statistics |
| Load reports contain execution metrics                |
| Performance reports contain execution metrics         |
| Automatically expands when new dimensions appear      |
| Suitable for release evidence storage                 |

This is the CR that would automate exactly the markdown files you are currently writing manually.
