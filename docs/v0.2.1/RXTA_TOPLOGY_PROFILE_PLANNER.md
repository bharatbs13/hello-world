```markdown
# CR: Planner-Generated D Profiling for Connector Topology Coverage

## CR ID

`RELIX_AUTOMATION_TOPLOGY_PROFILE_PLANNER`

## Target Version

`v0.2.1` foundation

## Product

Relix Automation Test Framework

---

## 1. Objective

Introduce planner-generated `D` profiles for solution-specific connector topology coverage.

`D` represents one concrete infrastructure combination selected for a test run.

Example:

```text
D1 = postgres_to_postgres
D2 = postgres_to_mysql
D3 = mysql_to_oracle
```

D must not be a permanent global catalog.
It must be generated per run by the automation planner.

---

## 2. Problem

As connector support grows, topology combinations can explode.

Example:

| Connectors (N) | Source-Target Combinations |
|----------------|----------------------------|
| 10             | 10 × 10 = 100              |

If every functional, load, and performance run executes all combinations, testing becomes expensive and unmanageable.

A static global catalog like:

| D ID   | Infra Signature          |
|--------|--------------------------|
| D1     | postgres_to_postgres     |
| D2     | postgres_to_mysql        |
| ...    | ...                      |
| D100   | snowflake_to_oracle      |

is not scalable.

---

## 3. Core Design

D is generated at execution time.

| Step | Description                                              |
|------|----------------------------------------------------------|
| 1    | `solution` defines topology shape                        |
| 2    | `connector pool` defines available connector types       |
| 3    | Planner selects concrete combinations                    |
| 4    | Selected combinations become D profiles                  |

---

## 4. Terminology

| Term                | Meaning                                                        |
|---------------------|----------------------------------------------------------------|
| solution            | Workload family, e.g. core_runtime, migration, reconciliation |
| topology_shape      | Required infrastructure roles, e.g. none, single_db, source_target |
| connector_pool      | Candidate connector types, e.g. postgres, mysql, oracle        |
| D profile           | One generated execution member                                 |
| infra_signature     | Human-readable combination, e.g. postgres_to_mysql             |
| depth_strategy      | Strategy used to select D profiles                             |
| max_depth_profiles  | Cap on number of generated D profiles                          |

---

## 5. Example

### Input

| Parameter           | Value                          |
|---------------------|--------------------------------|
| solution            | migration                      |
| topology_shape      | source_target                  |
| connector_pool      | postgres, mysql, oracle        |
| depth_strategy      | random                         |
| max_depth_profiles  | 3                              |
| random_seed         | 42                             |

### Generated D Map

| D   | Infra Signature        | Source Connector | Target Connector |
|-----|------------------------|------------------|------------------|
| D1  | postgres_to_mysql      | postgres         | mysql            |
| D2  | oracle_to_postgres     | oracle           | postgres         |
| D3  | mysql_to_mysql         | mysql            | mysql            |

---

## 6. D Is Run-Scoped

D1 is only meaningful inside one run.
Another run may generate a different mapping.

Therefore every report must include the run-level D map.

### Example

```json
{
  "run_id": "perf_load_20260608_abcd",
  "d_profile_map": {
    "D1": {
      "infra_signature": "postgres_to_mysql",
      "source_connector": "postgres",
      "target_connector": "mysql"
    },
    "D2": {
      "infra_signature": "oracle_to_postgres",
      "source_connector": "oracle",
      "target_connector": "postgres"
    }
  }
}
```

---

## 7. Supported Depth Strategies

### 7.1 exhaustive

Generate all valid combinations.

| Parameter        | Value        |
|------------------|--------------|
| depth_strategy   | exhaustive   |

Use for small connector pools.

---

### 7.2 random

Randomly sample combinations up to cap.

| Parameter           | Value   |
|---------------------|---------|
| depth_strategy      | random  |
| max_depth_profiles  | 5       |
| random_seed         | 42      |

Use for large connector pools.

---

### 7.3 critical_only

Run only explicitly marked critical combinations.

| Parameter           | Value                              |
|---------------------|------------------------------------|
| depth_strategy      | critical_only                      |
| critical_profiles   | postgres_to_postgres, postgres_to_mysql |

Use for release gates.

---

### 7.4 smoke

Run a minimal representative set.

| Parameter        | Value   |
|------------------|---------|
| depth_strategy   | smoke   |

Example profiles:

| D   | Infra Signature      |
|-----|----------------------|
| D0  | mock                 |
| D1  | postgres_to_postgres |

Use for quick validation.

---

## 8. Topology Shapes

### none

No external infrastructure.

| Example                  |
|--------------------------|
| mock functional tests    |

D map:

| D   | Infra Signature |
|-----|-----------------|
| D0  | mock            |

---

### single_db

One database role.

| Example                  |
|--------------------------|
| connector validation     |

Generated profiles:

| D   | Connector |
|-----|-----------|
| D1  | postgres  |
| D2  | mysql     |
| D3  | oracle    |

---

### source_target

Two database roles.

| Example                  |
|--------------------------|
| core_runtime             |
| migration                |
| reconciliation           |

Generated profiles:

| D   | Infra Signature        |
|-----|------------------------|
| D1  | postgres_to_postgres   |
| D2  | postgres_to_mysql      |
| D3  | mysql_to_postgres      |

---

## 9. Applicability Across Test Scopes

D profiling is available for all scopes but only used when applicable.

| Scope         | D Required? | Notes                                               |
|---------------|-------------|-----------------------------------------------------|
| feature       | optional    | Required for connector/topology functional coverage |
| regression    | optional    | Required for connector regression matrix            |
| load          | optional    | Required when benchmarking topology combinations    |
| performance   | optional    | Required when comparing topology combinations       |
| parallelism   | optional    | Combined with worker cores when applicable          |

Rule:

| Rule                                    |
|-----------------------------------------|
| scope does not decide D                 |
| solution topology decides D             |

---

## 10. Execution Matrix Integration

### Functional

| Dimension 1 | Dimension 2 | Dimension 3 |
|-------------|-------------|-------------|
| solution    | D           | test_case   |

### Load

| Dimension 1 | Dimension 2 | Dimension 3 |
|-------------|-------------|-------------|
| solution    | D           | tier        |

### Performance

| Dimension 1 | Dimension 2 | Dimension 3 | Dimension 4 |
|-------------|-------------|-------------|-------------|
| solution    | D           | tier        | batch_size  |

### Parallelism

| Dimension 1 | Dimension 2 | Dimension 3 | Dimension 4 | Dimension 5  |
|-------------|-------------|-------------|-------------|--------------|
| solution    | D           | tier        | batch_size  | worker_cores |

---

## 11. Report Requirements

Every report using D must include:

| Requirement        | Level     |
|--------------------|-----------|
| d_profile_map      | Run-level |

Every execution row must include:

| Field               |
|---------------------|
| depth_id            |
| infra_signature     |
| topology_shape      |
| source_connector    |
| target_connector    |

where applicable.

---

## 12. Reporting Tables

### D Profile Map Table

| Depth ID | Topology Shape | Infra Signature        | Source Connector | Target Connector | Selection Strategy |
|----------|----------------|------------------------|------------------|------------------|--------------------|
| D1       | source_target  | postgres_to_mysql      | postgres         | mysql            | random             |
| D2       | source_target  | oracle_to_postgres     | oracle           | postgres         | random             |
| D3       | source_target  | mysql_to_mysql         | mysql            | mysql            | random             |

---

### Functional Summary Table

| Suite   | Solution  | Depth ID | Infra Signature        | Total Tests | Passed | Failed | Failed Case IDs |
|---------|-----------|----------|------------------------|-------------|--------|--------|-----------------|
| feature | migration | D1       | postgres_to_mysql      | 20          | 20     | 0      | []              |
| feature | migration | D2       | oracle_to_postgres     | 20          | 19     | 1      | [UAT-MIG-004]   |

---

### Load Summary Table

| Solution  | Depth ID | Infra Signature        | Tier       | Total Rows | Duration ms | Rows/sec | Status |
|-----------|----------|------------------------|------------|------------|-------------|----------|--------|
| migration | D1       | postgres_to_mysql      | tier_100k  | 100000     | 12200       | 8196     | PASSED |
| migration | D2       | oracle_to_postgres     | tier_100k  | 100000     | 15500       | 6451     | PASSED |

---

### Performance Summary Table

| Solution  | Depth ID | Infra Signature        | Tier       | Batch Size | Duration ms | Rows/sec | Status |
|-----------|----------|------------------------|------------|------------|-------------|----------|--------|
| migration | D1       | postgres_to_mysql      | tier_100k  | 1000       | 12200       | 8196     | PASSED |
| migration | D2       | oracle_to_postgres     | tier_100k  | 1000       | 15500       | 6451     | PASSED |

---

### Parallelism Summary Table

| Solution  | Depth ID | Infra Signature        | Tier       | Batch Size | Worker Cores | Rows/sec | Speedup vs 1 Core | Status |
|-----------|----------|------------------------|------------|------------|--------------|----------|--------------------|--------|
| migration | D1       | postgres_to_mysql      | tier_100k  | 1000       | 1            | 6000     | 1.00               | PASSED |
| migration | D1       | postgres_to_mysql      | tier_100k  | 1000       | 4            | 14500    | 2.42               | PASSED |

---

## 13. Config Proposal

```yaml
d_profile_planner:
  enabled: true

  default_strategy: smoke
  default_max_depth_profiles: 3
  random_seed: 42

solutions:
  core_runtime:
    topology_shape: source_target
    connector_pool:
      - postgres
    depth_strategy: exhaustive

  migration:
    topology_shape: source_target
    connector_pool:
      - postgres
      - mysql
      - oracle
    depth_strategy: random
    max_depth_profiles: 5

  reconciliation:
    topology_shape: source_target
    connector_pool:
      - postgres
      - mysql
    depth_strategy: exhaustive
```

---

## 14. Planner Output

```json
{
  "solution": "migration",
  "topology_shape": "source_target",
  "depth_strategy": "random",
  "max_depth_profiles": 3,
  "random_seed": 42,
  "d_profile_map": {
    "D1": {
      "infra_signature": "postgres_to_mysql",
      "source_connector": "postgres",
      "target_connector": "mysql"
    },
    "D2": {
      "infra_signature": "oracle_to_postgres",
      "source_connector": "oracle",
      "target_connector": "postgres"
    },
    "D3": {
      "infra_signature": "mysql_to_mysql",
      "source_connector": "mysql",
      "target_connector": "mysql"
    }
  }
}
```

---

## 15. Acceptance Criteria

| ID   | Criteria                                                                                   |
|------|--------------------------------------------------------------------------------------------|
| AC1  | D profiles must be generated per run, not globally hardcoded                               |
| AC2  | Reports must include the D mapping used for that run                                       |
| AC3  | Planner must support: exhaustive, random, critical_only, smoke strategies                  |
| AC4  | Planner must support cap: max_depth_profiles                                               |
| AC5  | Random strategy must support deterministic replay using: random_seed                       |
| AC6  | D profiles must be available to: feature, regression, load, performance, parallelism but only used when applicable |
| AC7  | Solution-specific workload/test code must receive resolved D context                       |
| AC8  | Automation must not hardcode connector combinations in test runner logic                   |

---

## 16. Final Decision

| Principle                                                                 |
|---------------------------------------------------------------------------|
| D is a planner-generated, run-scoped topology member                      |
| It is not a permanent catalog                                             |
| The automation planner controls which D profiles run                      |
| The solution-specific workload controls how each D profile is interpreted |
| This keeps Relix automation scalable as connector count grows             |
```
