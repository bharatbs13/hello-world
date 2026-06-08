# CR: Phase 2 Multi-Dimensional Load and Performance Testing

## CR ID

`RELIX_TOOLS_CR_P2_LOAD_PERF_MULTI_DIM`

## Target Versions

| Version | Scope |
|---|---|
| `v0.2.1` | Multi-dimensional load/performance reporting without parallelism |
| `v0.2.2` | Parallelism testing using `num_cores` |

---

## Goal

Support Phase 2 load/performance testing across multiple dimensions:

```text
phase
domain
suite
solution
db_type
tier
batch_size
relix_vm_ip
detected_vcpu
detected_memory_gb
````

Reserve `v0.2.2` for:

```text
parallelism_enabled
num_cores
```

---

## Report Path

### Load

```text
reports/{version}/{run_mode}/{run_id}/phase2/{domain}/load/{solution}/{db_type}/{tier}/
```

Example:

```text
reports/0.2.1/perf/{run_id}/phase2/backend/load/core_runtime/postgres/tier_100k/
```

### Performance

```text
reports/{version}/{run_mode}/{run_id}/phase2/{domain}/performance/{solution}/{db_type}/{tier}/batch_{batch_size}/
```

Example:

```text
reports/0.2.1/perf/{run_id}/phase2/backend/performance/core_runtime/postgres/tier_100k/batch_1000/
```

### Parallelism — v0.2.2

```text
reports/{version}/{run_mode}/{run_id}/phase2/{domain}/performance/{solution}/{db_type}/{tier}/vm_{relix_vm_ip}/cores_{num_cores}/batch_{batch_size}/
```

Example:

```text
reports/0.2.2/perf/{run_id}/phase2/backend/performance/core_runtime/postgres/tier_100k/vm_10_160_0_7/cores_4/batch_1000/
```

---

## CLI Additions

### v0.2.1

```bash
relix-deploy test \
  --version 0.2.1 \
  --run-mode perf \
  --phase 2 \
  --suite load \
  --tier tier_100k \
  --db-type postgres \
  --solution core_runtime
```

### v0.2.2

```bash
relix-deploy test \
  --version 0.2.2 \
  --run-mode perf \
  --phase 2 \
  --suite performance \
  --tier tier_100k \
  --db-type postgres \
  --solution core_runtime \
  --relix-vm-ip 10.160.0.7 \
  --num-cores 4
```

---

## Runtime VM Handling

`relix_vm_ip` should be accepted as CLI/env input.

Example env fallback:

```bash
export RELIX_VM_IP=10.160.0.7
```

The tool should discover actual VM capacity at runtime:

```bash
nproc
free -g
```

Metrics must record:

```json
{
  "relix_vm_ip": "10.160.0.7",
  "detected_vcpu": 4,
  "detected_memory_gb": 16
}
```

For `v0.2.2`, validate:

```text
num_cores <= detected_vcpu
```

---

## Infrastructure Model

Do not hardcode DB type in test code.

Add config-driven database metadata:

```yaml
infrastructure:
  databases:
    - id: pg_source
      type: postgres
      role: source
      env_var: RELIX_SOURCE_DB_URL

    - id: pg_target
      type: postgres
      role: target
      env_var: RELIX_TARGET_DB_URL
```

Solution-specific infra requirements:

```yaml
solutions:
  core_runtime:
    required_databases:
      - role: source
      - role: target
```

For migration-style solutions:

```yaml
solutions:
  migration:
    required_databases:
      - role: source
      - role: target
```

The automation resolves:

```text
solution -> required database roles -> db_type -> env vars
```

---

## Test Matrix Config

### Load Matrix — v0.2.1

```yaml
load_matrix:
  enabled: true
  phase: 2
  domain: backend
  solution: core_runtime
  db_types:
    - postgres
  tiers:
    - id: tier_smoke
      orders: 100
      customers: 50
      batch_size: 25

    - id: tier_10k
      orders: 10000
      customers: 1000
      batch_size: 500

    - id: tier_100k
      orders: 100000
      customers: 10000
      batch_size: 1000

    - id: tier_1m
      orders: 1000000
      customers: 100000
      batch_size: 5000
```

### Performance Matrix — v0.2.1

```yaml
performance_matrix:
  enabled: true
  phase: 2
  domain: backend
  solution: core_runtime
  db_types:
    - postgres
  tiers:
    - id: tier_10k
      orders: 10000
      customers: 1000
      batch_sizes:
        - 500
        - 1000

    - id: tier_100k
      orders: 100000
      customers: 10000
      batch_sizes:
        - 1000
        - 5000
```

### Parallelism Matrix — v0.2.2

```yaml
parallelism_matrix:
  enabled: true
  phase: 2
  domain: backend
  solution: core_runtime
  db_types:
    - postgres
  tiers:
    - id: tier_100k
      orders: 100000
      customers: 10000
      batch_sizes:
        - 1000
      num_cores:
        - 1
        - 2
        - 4

    - id: tier_1m
      orders: 1000000
      customers: 100000
      batch_sizes:
        - 5000
      num_cores:
        - 1
        - 2
        - 4
```

---

## Environment Variables Passed to Tests

### Load

```bash
RELIX_TEST_PHASE=phase2
RELIX_TEST_DOMAIN=backend
RELIX_TEST_SUITE=load
RELIX_TEST_SOLUTION=core_runtime
RELIX_TEST_DB_TYPE=postgres
RELIX_LOAD_TIER=tier_100k
RELIX_LOAD_ORDERS=100000
RELIX_LOAD_CUSTOMERS=10000
RELIX_LOAD_BATCH_SIZE=1000
RELIX_REPORT_DIR=...
```

### Performance

```bash
RELIX_TEST_PHASE=phase2
RELIX_TEST_DOMAIN=backend
RELIX_TEST_SUITE=performance
RELIX_TEST_SOLUTION=core_runtime
RELIX_TEST_DB_TYPE=postgres
RELIX_PERF_TIER=tier_100k
RELIX_PERF_ORDERS=100000
RELIX_PERF_CUSTOMERS=10000
RELIX_PERF_BATCH_SIZE=1000
RELIX_REPORT_DIR=...
```

### Parallelism — v0.2.2

```bash
RELIX_PARALLELISM_ENABLED=true
RELIX_NUM_CORES=4
RELIX_RELIX_VM_IP=10.160.0.7
RELIX_DETECTED_VCPU=4
RELIX_DETECTED_MEMORY_GB=16
```

---

## Metrics Schema

### Load

```json
{
  "test_id": "LOAD-V02-001",
  "phase": "phase2",
  "domain": "backend",
  "suite": "load",
  "solution": "core_runtime",
  "db_type": "postgres",
  "tier": "tier_100k",
  "orders": 100000,
  "customers": 10000,
  "batch_size": 1000,
  "relix_vm_ip": "10.160.0.7",
  "detected_vcpu": 4,
  "detected_memory_gb": 16,
  "total_rows": 100000,
  "tables_completed": 2,
  "duration_ms": 12345.67,
  "rows_per_second": 8100.23,
  "status": "PASSED"
}
```

### Performance

```json
{
  "test_id": "PERF-V02-001",
  "phase": "phase2",
  "domain": "backend",
  "suite": "performance",
  "solution": "core_runtime",
  "db_type": "postgres",
  "tier": "tier_100k",
  "batch_size": 1000,
  "relix_vm_ip": "10.160.0.7",
  "detected_vcpu": 4,
  "detected_memory_gb": 16,
  "duration_ms": 12345.67,
  "rows_per_second": 8100.23,
  "p95_batch_ms": null,
  "peak_memory_mb": null,
  "status": "PASSED"
}
```

### Parallelism — v0.2.2

```json
{
  "test_id": "PARALLEL-PERF-V02-001",
  "phase": "phase2",
  "domain": "backend",
  "suite": "performance",
  "solution": "core_runtime",
  "db_type": "postgres",
  "tier": "tier_100k",
  "batch_size": 1000,
  "parallelism_enabled": true,
  "num_cores": 4,
  "relix_vm_ip": "10.160.0.7",
  "detected_vcpu": 4,
  "detected_memory_gb": 16,
  "duration_ms": 8000.12,
  "rows_per_second": 12500.45,
  "speedup_vs_single_core": 1.8,
  "status": "PASSED"
}
```

---

## Aggregated Reports

Aggregation is Phase 2 only.

### Load Aggregate

```text
reports/{version}/{run_mode}/{run_id}/phase2/backend/load/aggregate/load_summary.json
reports/{version}/{run_mode}/{run_id}/phase2/backend/load/aggregate/load_summary.md
```

Group by:

```text
solution
db_type
tier
```

### Performance Aggregate

```text
reports/{version}/{run_mode}/{run_id}/phase2/backend/performance/aggregate/performance_summary.json
reports/{version}/{run_mode}/{run_id}/phase2/backend/performance/aggregate/performance_summary.md
```

Group by:

```text
solution
db_type
tier
batch_size
```

### Parallelism Aggregate — v0.2.2

```text
reports/{version}/{run_mode}/{run_id}/phase2/backend/performance/aggregate/parallelism_summary.json
reports/{version}/{run_mode}/{run_id}/phase2/backend/performance/aggregate/parallelism_summary.md
```

Group by:

```text
solution
db_type
tier
batch_size
relix_vm_ip
num_cores
```

---

## Acceptance Criteria

### AC1

Load and performance tests must support:

```text
solution
db_type
tier
batch_size
domain
relix_vm_ip
```

as report dimensions.

### AC2

`v0.2.2` must add:

```text
num_cores
parallelism_enabled
detected_vcpu
detected_memory_gb
```

as first-class metrics.

### AC3

`num_cores` must be rejected if:

```text
num_cores > detected_vcpu
```

### AC4

No load/performance test should hardcode PostgreSQL as the only possible DB type.

### AC5

For `v0.2.1`, only `postgres` is required, but report schema must already include `db_type`.

### AC6

Aggregation must be separate for:

```text
load
performance
parallelism
```

### AC7

Solution-specific Python should own workload behavior.

Infrastructure resolution should be generic.

---

## Implementation Phases

### v0.2.1

Implement:

```text
tier dimension
db_type dimension
solution dimension
load/performance aggregate reports
config-driven workload env vars
```

### v0.2.2

Implement:

```text
num_cores CLI arg
relix_vm_ip CLI arg/env override
remote VM capacity detection
parallelism metrics
parallelism aggregate report
```

---

## Final Design Principle

Do not encode future DBs or future solutions into bash scripts.

Keep:

```text
infrastructure resolution generic
solution workload specific
report dimensions explicit
parallelism separate in v0.2.2
```

