# UAT Specification – Relix v0.2.2

## Validation Strategy

v0.2.2 validates adapter expansion only. Framework behavior (FR-034, FR-035, FR-036, FR-037) is inherited from v0.2.1 and accepted without re-execution unless regression is observed.

---

## Inherited UAT Coverage

Relix v0.2.2 inherits the UAT coverage established by:

| Version | FR | Coverage |
|----------|----------|----------|
| v0.2.1 | FR-034 | Universal Connector Adapter Framework |
| v0.2.1 | FR-035 | Access Profile Framework |
| v0.2.1 | FR-036 | Connector Profile Binding |
| v0.2.1 | FR-037 | Transport Encryption Validation |

The objective of v0.2.2 is not to revalidate inherited framework behavior.

v0.2.2 validates only the additional adapter implementations introduced by FR-038 and their participation within the existing FR-034 framework.

Framework behavior previously accepted in v0.2.1 is considered inherited unless regression is observed during v0.2.2 execution.

---

## UAT Inheritance Rule

| Rule |
|------|
| Inherited UAT coverage from v0.2.1 SHALL be accepted without re-execution. |
| Regression in inherited behavior observed during v0.2.2 execution SHALL be reported as a blocking issue. |
| No formal re-certification of FR-034, FR-035, FR-036, or FR-037 is required for v0.2.2. |

---

## Common Environment

### Required Components

| Component | Required |
|-----------|----------|
| Relix Runtime | Yes |
| Connector Registry | Yes |
| Supported Connector Registry | Yes |
| Adapter Registry | Yes |
| PostgreSQL Native Connector | Yes |
| At Least One Adapter-Backed Connector | Yes |
| AirbyteConnectorAdapter | Yes |
| SingerMeltanoConnectorAdapter | Yes |

### Optional Components

| Component | Required |
|-----------|----------|
| DltConnectorAdapter | No |

### Connector Policies

| Policy |
|--------|
| native_only |
| adapter_only |
| native_preferred |
| adapter_preferred |

---

## Test Case ID Convention

```text
UAT-V022-FUNC-<CLASS>-<NNN>
```

### Test Class Convention

| Class | Description |
|---------|-------------|
| ADAPTER | Adapter registration, discovery, and resolution |
| PREFLIGHT | Capability mapping and preflight validation |
| FREEZE_STABILITY | Immutability guarantees for frozen execution plans |

### Test Case Format

```text
<TEST_ID> — <Short Test Name>

Class: <CLASS>

Condition:
What must be configured or triggered.

Description:
What behavior is being validated.

Acceptance Criteria:

· Expected result 1
· Expected result 2
· Expected result 3
```

---

## Adapter Execution Matrix

| Validation | AirbyteConnectorAdapter | SingerMeltanoConnectorAdapter |
|------------|------------------------|-------------------------------|
| Adapter Registration | Yes |
| Connector Discovery | Yes | Yes |
| Single Candidate Resolution | Yes | Yes |
| Multiple Candidate Discovery | Yes | Yes |
| Policy-Based Selection | Yes | Yes |
| Capability-Aware Resolution | Yes | Yes |
| Supported Connector Registry Enforcement | Yes | Yes |
| Capability Mapping | Yes | Yes |
| Representative Execution | Yes | Yes |
| Freeze Stability | Yes | Yes |

---

## Regression Execution Rule

Inherited framework behavior is validated through regression execution only.

v0.2.2 SHALL NOT require exhaustive re-execution of the complete v0.2.1 functional suite against every adapter implementation.

Validation focus SHALL be limited to:

- adapter registration
- adapter discovery
- connector resolution
- connector selection policy behavior
- capability-aware resolution
- supported connector registry enforcement
- capability declaration mapping
- representative execution validation
- freeze-time resolution stability

Additional regression coverage MAY be executed at the discretion of the test operator.

---

## Adapter Execution Rule

Each adapter implementation introduced by FR-038 SHALL satisfy the applicable validations defined in the Adapter Execution Matrix.

The UAT identifier remains unchanged across execution runs.

Execution metadata SHALL identify adapter implementation, connector type, and execution run identifier.

---

# UAT Area – FR-038 Additional Adapter Implementations

## Objective

Validate that newly introduced adapter implementations correctly participate in the existing FR-034 Universal Connector Adapter Framework.

This UAT area validates adapter implementation expansion only.

Framework behavior previously accepted under FR-034 is inherited from v0.2.1 and is not re-certified unless regression is observed.

---

## UAT-V022-FUNC-ADAPTER-001 — Adapter Registration

**Class:** `ADAPTER`

### Condition

Adapter implementation is installed and configured.

### Description

Validate that the adapter registers successfully with the Adapter Registry.

### Acceptance Criteria

- Adapter registration succeeds
- Adapter appears in Adapter Registry
- Adapter metadata is retrievable
- Adapter is available for connector discovery

---

## UAT-V022-FUNC-ADAPTER-002 — Connector Discovery

**Class:** `ADAPTER`

### Condition

Adapter is registered and enabled.

### Description

Validate that connector types supported by the adapter are exposed through connector discovery.

### Acceptance Criteria

- Supported connector types are discoverable
- Unsupported connector types are not advertised
- Discovery results are deterministic
- Discovery metadata is available

---

## UAT-V022-FUNC-ADAPTER-003 — Single Candidate Resolution

**Class:** `ADAPTER`

### Condition

Requested connector is supported by exactly one enabled adapter implementation.

### Description

Validate connector resolution when a single adapter candidate exists.

### Acceptance Criteria

- Connector resolution succeeds
- Correct adapter is selected
- No policy evaluation is required
- Resolution result is deterministic

### Example

```text
Connector: Snowflake
  AirbyteConnectorAdapter       → supports
  SingerMeltanoConnectorAdapter → not supported

Result: AirbyteConnectorAdapter selected
```

---

## UAT-V022-FUNC-ADAPTER-004 — Multiple Candidate Discovery

**Class:** `ADAPTER`

### Condition

Requested connector is supported by multiple enabled adapter implementations.

### Description

Validate that all eligible adapter candidates are discovered when multiple adapters support the same connector.

### Acceptance Criteria

- All supporting adapters appear in the candidate set
- Candidate set is complete
- Candidate set is deterministic
- No unsupported adapters appear in the candidate set

### Example

```text
Connector: Snowflake
  AirbyteConnectorAdapter       → supports
  SingerMeltanoConnectorAdapter → supports

Candidate Set:
{AirbyteConnectorAdapter, SingerMeltanoConnectorAdapter}
```

---

## UAT-V022-FUNC-ADAPTER-005 — Policy-Based Selection

**Class:** `ADAPTER`

### Condition

Multiple adapter candidates exist for the requested connector. Connector selection policy is configured.

### Description

Validate that the connector selection policy correctly determines the winning adapter from the candidate set.

### Acceptance Criteria

- With `adapter_preferred`, an adapter candidate is selected
- With `native_preferred`, an adapter candidate is selected when no native implementation exists
- With `adapter_only`, an adapter candidate is selected
- With `native_only`, resolution fails when no native implementation exists
- Selection result is deterministic for the same policy and candidate set

### Example

```text
Candidate Set:
{AirbyteConnectorAdapter, SingerMeltanoConnectorAdapter}

Policy: adapter_preferred → adapter candidate selected
Policy: native_preferred  → adapter candidate selected (no native exists)
Policy: adapter_only      → adapter candidate selected
Policy: native_only       → resolution fails (no native exists)
```

---

## UAT-V022-FUNC-ADAPTER-006 — Capability-Aware Resolution

**Class:** `ADAPTER`

### Condition

Multiple adapter candidates support the requested connector but offer different capability sets. Required capabilities are specified.

### Description

Validate that connector resolution eliminates candidates that do not satisfy required capabilities and selects from the remaining eligible candidates.

### Acceptance Criteria

- Multiple candidates are discovered
- Candidates are evaluated against required capabilities
- Ineligible candidates are removed from consideration
- An eligible candidate is selected deterministically
- If no candidate satisfies required capabilities, resolution fails

### Example

```text
Connector: Snowflake

AirbyteConnectorAdapter:
  capabilities: read, write

SingerMeltanoConnectorAdapter:
  capabilities: read, write, create_table

Required capabilities:
  read
  write
  create_table

Candidate Set:
{AirbyteConnectorAdapter, SingerMeltanoConnectorAdapter}

After capability evaluation:
{SingerMeltanoConnectorAdapter}

Result:
SingerMeltanoConnectorAdapter selected
```

---

## UAT-V022-FUNC-ADAPTER-007 — Supported Connector Registry Enforcement

**Class:** `ADAPTER`

### Condition

An enabled adapter supports the requested connector. The connector is disabled in the Supported Connector Registry.

### Description

Validate that adapter capability does not override the Supported Connector Registry.

### Acceptance Criteria

- Adapter supports the connector
- Connector is disabled in Supported Connector Registry
- Connector resolution fails
- Error message confirms connector is not in Supported Connector Registry
- Adapter support does not override registry enforcement

### Example

```text
Connector: Snowflake

AirbyteConnectorAdapter → supports

Supported Connector Registry:
  Snowflake: disabled

Result:
Resolution fails. Connector not supported.
```

---

## UAT-V022-FUNC-PREFLIGHT-001 — Capability Mapping

**Class:** `PREFLIGHT`

### Condition

Adapter supports a connector participating in execution planning.

### Description

Validate that adapter-declared capabilities participate correctly in FR-034 capability validation.

### Acceptance Criteria

- Capability declarations are exposed
- Capability validation succeeds for supported operations
- Missing capabilities are detected
- Validation failures are reported clearly

---

## UAT-V022-FUNC-ADAPTER-008 — Representative Execution

**Class:** `ADAPTER`

### Condition

Execution plan uses an adapter-backed connector.

### Description

Validate successful execution using the resolved adapter implementation.

### Acceptance Criteria

- Connector resolution succeeds
- Execution plan freeze succeeds
- Execution completes successfully using the resolved adapter implementation
- Checkpoint creation succeeds
- Reconciliation metadata remains consistent

---

## UAT-V022-FUNC-FREEZE_STABILITY-001 — Freeze-Time Resolution Stability

**Class:** `FREEZE_STABILITY`

### Condition

Execution plan is frozen using an adapter-backed connector.

### Description

Validate that the resolved adapter implementation remains stable for the lifetime of the frozen plan.

### Acceptance Criteria

- Frozen plan retains resolved adapter
- Recovery uses the same adapter
- Replay uses the same adapter
- Resolution is not re-evaluated after freeze

---

## UAT-V022-FUNC-FREEZE_STABILITY-002 — Disabled Adapter Excluded From New Resolution

**Class:** `FREEZE_STABILITY`

### Condition

Adapter is disabled after registration.

### Description

Validate that disabled adapters are excluded from future connector resolution.

### Acceptance Criteria

- Disabled adapter is not considered during new resolution
- New execution plans cannot select the disabled adapter
- Existing frozen plans remain unaffected
- Existing recovery operations continue to function

---

## UAT-V022-FUNC-FREEZE_STABILITY-003 — Deregistered Adapter Does Not Affect Frozen Plans

**Class:** `FREEZE_STABILITY`

### Condition

Execution plan is frozen using an adapter-backed connector. The adapter is subsequently deregistered.

### Description

Validate that adapter deregistration does not invalidate frozen execution plans.

### Acceptance Criteria

- Existing frozen plan continues to execute successfully
- Recovery uses the previously resolved adapter implementation
- Replay uses the previously resolved adapter implementation
- Deregistered adapter is unavailable for new connector resolution
- Existing frozen plan remains unaffected

---

## Acceptance Criteria

v0.2.2 UAT is complete when all of the following requirements are satisfied:

| Requirement | Status |
|-------------|--------|
| AirbyteConnectorAdapter passes all FR-038 execution matrix validations | Required |
| SingerMeltanoConnectorAdapter passes all FR-038 execution matrix validations | Required |
| Connector resolution policies behave correctly per FR-034 defined modes | Required |
| Capability-aware resolution correctly filters ineligible candidates | Required |
| Supported Connector Registry enforcement works for adapter-backed connectors | Required |
| Capability mapping behaves correctly | Required |
| Representative execution succeeds for each adapter | Required |
| Freeze stability guarantees remain intact | Required |
| Adapter deregistration does not invalidate frozen execution plans | Required |
| No FR-034 framework changes are required | Required |
| No regression identified in inherited behavior | Required |

---

## Traceability

| FR | Coverage Location |
|----|-------------------|
| FR-034 | Inherited from v0.2.1 |
| FR-035 | Inherited from v0.2.1 |
| FR-036 | Inherited from v0.2.1 |
| FR-037 | Inherited from v0.2.1 |
| FR-038 | UAT Area FR-038 + Adapter Execution Matrix + Acceptance Criteria |

---
