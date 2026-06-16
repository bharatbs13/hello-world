# Relix v0.2.2 Functional UAT Specification

## 1. Scope

Functional UAT only.

### Covers
- license validation
- entitlement validation
- capability authorization
- expiry handling
- grace period handling
- frozen execution protection
- license observability
- license audit metadata

### Excludes
- billing
- invoicing
- subscription management
- payment processing
- usage reporting
- SaaS control plane
- UI validation
- security penetration testing
- performance testing
- load testing

---

## 2. Common Environment Setup

- Relix runtime deployed
- license governance framework enabled
- license registry configured
- entitlement registry configured
- capability registry configured
- sample valid license available
- sample expired license available
- sample trial license available
- sample perpetual license available
- sample malformed license available
- capability `internal_data_plane_parallelism` registered for entitlement checks
- capability `topology_optimization` registered for future capability checks
- event store enabled
- audit metadata store enabled
- frozen execution plan fixture available

---

## 3. Test Case ID Convention

```text
UAT-V022-FUNC-<CLASS>-<NNN>
```

---

4. Test Class Convention

Class Description
LICENSE License validation and lifecycle behavior
ENTITLEMENT Entitlement lookup and authorization
CAPABILITY_AUTHORIZATION Capability authorization decisions
EXPIRY Expiry and grace-period behavior
FREEZE_STABILITY Frozen-plan continuation behavior
OBSERVABILITY License governance events
AUDITABILITY License decision audit metadata
ERROR_SEMANTICS Invalid license and failure behavior

---

5. Test Case Format

<TEST_ID> — <Short Test Name>

Class: <CLASS>

Condition:
What must be configured or triggered.

Description:
What behavior is being validated.

Acceptance Criteria

· Expected result 1
· Expected result 2
· Expected event/error if applicable

---

UAT Area 1 — License Validation

Positive Functional Cases

UAT-V022-FUNC-LICENSE-001 — Valid License Accepted

Class: LICENSE

Condition
Valid license exists with expiry in future.

Description
Validate that the license governance framework accepts a valid active license.

Acceptance Criteria

· License validation succeeds
· License status is active
· License identifier is available in validation result
· LICENSE_VALIDATION_PASSED event emitted

---

UAT-V022-FUNC-LICENSE-002 — Perpetual License Accepted

Class: LICENSE

Condition
Perpetual license exists with no expiry.

Description
Validate that a perpetual license is accepted without expiry checks.

Acceptance Criteria

· License validation succeeds
· License status is active
· No expiry check is performed
· License identifier is available in validation result

---

UAT-V022-FUNC-LICENSE-003 — Trial License Accepted

Class: LICENSE

Condition
Trial license exists with expiry in future.

Description
Validate that a trial license is accepted and trial metadata is present.

Acceptance Criteria

· License validation succeeds
· License status is active
· Trial metadata is present in validation result
· License type is identified as trial

---

Negative Functional Cases

UAT-V022-FUNC-LICENSE-004 — Expired License Rejected

Class: LICENSE

Condition
Expired license exists.

Description
Validate that an expired license is rejected.

Acceptance Criteria

· License validation fails
· LICENSE_VALIDATION_FAILED event emitted
· LICENSE_EXPIRED event emitted
· Error message indicates license expiry

---

UAT-V022-FUNC-LICENSE-005 — Invalid License Format Rejected

Class: ERROR_SEMANTICS

Condition
Malformed license file exists.

Description
Validate that a malformed license is rejected with an actionable error.

Acceptance Criteria

· License validation fails
· Error message is actionable for the operator
· Error message does not contain raw parsing stack trace
· License is not registered

---

UAT Area 2 — Entitlement Validation

Positive Functional Cases

UAT-V022-FUNC-ENTITLEMENT-001 — Entitlement Present Authorizes Capability

Class: ENTITLEMENT

Condition
Capability internal_data_plane_parallelism is registered. Entitlement internal_data_plane_parallelism exists in license.

Description
Validate that a capability is authorized when the corresponding entitlement is present.

Acceptance Criteria

· Entitlement lookup succeeds
· Authorization returns allowed
· Capability is granted
· Audit metadata records the decision

---

Negative Functional Cases

UAT-V022-FUNC-ENTITLEMENT-002 — Missing Entitlement Denies Capability

Class: ENTITLEMENT

Condition
Capability internal_data_plane_parallelism is registered. No entitlement exists for this capability.

Description
Validate that a capability is denied when no entitlement is present.

Acceptance Criteria

· Authorization returns denied
· LICENSE_ENTITLEMENT_DENIED event emitted
· Error message identifies the missing entitlement
· Capability is not granted

---

UAT-V022-FUNC-ENTITLEMENT-003 — Unknown Entitlement Ignored with Warning

Class: ERROR_SEMANTICS

Condition
License contains an unknown entitlement not registered in the entitlement registry.

Description
Validate that unknown entitlements are ignored, known entitlements are applied, and a warning is emitted.

Acceptance Criteria

· Unknown entitlement is ignored
· Known entitlements are applied normally
· Warning/audit entry is emitted for unknown entitlement
· License validation does not fail due to unknown entitlement

---

UAT Area 3 — Capability Authorization

Positive Functional Cases

UAT-V022-FUNC-CAPABILITY_AUTHORIZATION-001 — Future Capability Requires No Framework Modification

Class: CAPABILITY_AUTHORIZATION

Condition
Capability topology_optimization is registered. No special-case code exists for this capability.

Description
Validate that registering a future capability requires no modification to the license governance framework.

Acceptance Criteria

· Capability registration succeeds
· Authorization evaluation completes through standard path
· No framework code changes were required
· Capability is evaluable through the standard entitlement mechanism

---

UAT Area 4 — Expiry and Grace Period

Positive Functional Cases

UAT-V022-FUNC-EXPIRY-001 — Grace Period Active Applies Configured Policy

Class: EXPIRY

Condition
License expired. Grace period is active.

Description
Validate that the configured grace policy is applied when the license is expired but within the grace period.

Acceptance Criteria

· Authorization evaluated
· Configured grace policy is applied
· Grace period metadata is present in audit record
· Execution is permitted or denied per grace policy

---

Negative Functional Cases

UAT-V022-FUNC-EXPIRY-002 — Grace Period Expired Denies Authorization

Class: EXPIRY

Condition
License expired. Grace period has expired.

Description
Validate that authorization is denied when both the license and grace period are expired.

Acceptance Criteria

· Authorization denied
· LICENSE_EXPIRED event emitted
· Error message indicates grace period has expired
· No grace policy is applied

---

UAT Area 5 — Frozen Execution Protection

Positive Functional Cases

UAT-V022-FUNC-FREEZE_STABILITY-001 — Frozen Execution Continues After License Expiry

Class: FREEZE_STABILITY

Condition
Execution plan frozen while license was valid. License subsequently expires.

Description
Validate that a previously frozen execution plan continues to execute under frozen-plan protection after license expiry.

Acceptance Criteria

· The previously frozen execution plan resumes or continues
· Execution is permitted under frozen-plan protection
· New plan freeze remains subject to current license validation
· Audit metadata records frozen-plan protection applied

---

UAT-V022-FUNC-FREEZE_STABILITY-002 — Frozen Execution Continues After Entitlement Removal

Class: FREEZE_STABILITY

Condition
Execution plan frozen while entitlement existed. Entitlement subsequently removed from license.

Description
Validate that a frozen execution plan continues to execute when the required entitlement is later removed.

Acceptance Criteria

· The previously frozen execution plan resumes or continues
· Execution is permitted under frozen-plan protection
· New plan freeze is denied due to missing entitlement
· Audit metadata records frozen-plan protection applied

---

UAT Area 6 — Observability

Positive Functional Cases

UAT-V022-FUNC-OBSERVABILITY-001 — License Validation Events Emitted

Class: OBSERVABILITY

Condition
License validation is executed.

Description
Validate that license governance events are emitted into the event stream.

Acceptance Criteria

· LICENSE_VALIDATION_STARTED event emitted
· LICENSE_VALIDATION_PASSED event emitted on success
· LICENSE_VALIDATION_FAILED event emitted on failure
· Events include license_id and timestamp

---

UAT-V022-FUNC-OBSERVABILITY-002 — License Expiry Event Emitted

Class: OBSERVABILITY

Condition
Expired license is validated.

Description
Validate that a license expiry event is emitted.

Acceptance Criteria

· LICENSE_EXPIRED event emitted
· Event includes license_id and expiry timestamp
· Event is emitted before LICENSE_VALIDATION_FAILED

---

UAT-V022-FUNC-OBSERVABILITY-003 — Entitlement Denied Event Emitted

Class: OBSERVABILITY

Condition
Capability is evaluated without a matching entitlement.

Description
Validate that an entitlement denied event is emitted.

Acceptance Criteria

· LICENSE_ENTITLEMENT_DENIED event emitted
· Event includes capability_id and license_id
· Event is emitted at the time of authorization decision

---

UAT-V022-FUNC-OBSERVABILITY-004 — Grace Period Event Emitted

Class: OBSERVABILITY

Condition
License expired but within active grace period.

Description
Validate that a grace period event is emitted when the license enters the grace period.

Acceptance Criteria

· LICENSE_GRACE_PERIOD_ENTERED event emitted
· Event contains license_id
· Event contains grace_expiry_timestamp
· Event is emitted once per grace-period entry

---

UAT Area 7 — Auditability

Positive Functional Cases

UAT-V022-FUNC-AUDITABILITY-001 — License Decision Audit Metadata Generated

Class: AUDITABILITY

Condition
License validation or authorization decision is made.

Description
Validate that audit metadata is generated for every license governance decision, including both allow and deny outcomes.

Acceptance Criteria

· Audit record generated for allow decision
· Audit record generated for deny decision
· Audit output contains license_id
· Audit output contains capability_id
· Audit output contains entitlement
· Audit output contains decision (allow/deny)
· Audit output contains decision_rationale
· Audit output contains timestamp

---

UAT Area 8 — Edge Cases

UAT-V022-FUNC-ENTITLEMENT-004 — Duplicate Entitlement Normalized

Class: ENTITLEMENT

Condition
License contains duplicate entitlement entries for the same capability.

Description
Validate that duplicate entitlements are normalized into a set and validation continues.

Acceptance Criteria

· Duplicate entitlements are normalized
· Validation continues without error
· One entitlement is applied
· No conflict is generated

---

UAT-V022-FUNC-LICENSE-006 — License Not Required for Free Capability

Class: CAPABILITY_AUTHORIZATION

Condition
Capability declares license_required: false. No entitlement exists.

Description
Validate that a capability with license_required: false is authorized without entitlement lookup.

Acceptance Criteria

· Authorization succeeds
· No entitlement lookup is performed
· Capability is granted
· Audit metadata records license not required

---

Suite Mapping

Suite UATs
Smoke UAT-V022-FUNC-LICENSE-001, UAT-V022-FUNC-ENTITLEMENT-002
Sanity Smoke + UAT-V022-FUNC-LICENSE-004, UAT-V022-FUNC-ENTITLEMENT-001, UAT-V022-FUNC-CAPABILITY_AUTHORIZATION-001, UAT-V022-FUNC-FREEZE_STABILITY-001, UAT-V022-FUNC-OBSERVABILITY-001, UAT-V022-FUNC-AUDITABILITY-001
Full All UATs in this specification

---

Suite Summary

Suite Count Relationship
Smoke 2 Subset of Sanity / Full
Sanity 8 Subset of Full
Full 20 Complete coverage

---

Traceability

UAT FR AC Area
UAT-V022-FUNC-LICENSE-001 FR-038 — License Validation
UAT-V022-FUNC-LICENSE-002 FR-038 — License Validation
UAT-V022-FUNC-LICENSE-003 FR-038 — License Validation
UAT-V022-FUNC-LICENSE-004 FR-038 — License Validation
UAT-V022-FUNC-LICENSE-005 FR-038 — Error Semantics
UAT-V022-FUNC-LICENSE-006 FR-038 — Capability Authorization
UAT-V022-FUNC-ENTITLEMENT-001 FR-038 — Entitlement
UAT-V022-FUNC-ENTITLEMENT-002 FR-038 — Entitlement
UAT-V022-FUNC-ENTITLEMENT-003 FR-038 — Error Semantics
UAT-V022-FUNC-ENTITLEMENT-004 FR-038 — Entitlement
UAT-V022-FUNC-CAPABILITY_AUTHORIZATION-001 FR-038 AC8 Capability Authorization
UAT-V022-FUNC-EXPIRY-001 FR-038 — Expiry
UAT-V022-FUNC-EXPIRY-002 FR-038 — Expiry
UAT-V022-FUNC-FREEZE_STABILITY-001 FR-038 — Freeze Stability
UAT-V022-FUNC-FREEZE_STABILITY-002 FR-038 — Freeze Stability
UAT-V022-FUNC-OBSERVABILITY-001 FR-038 — Observability
UAT-V022-FUNC-OBSERVABILITY-002 FR-038 — Observability
UAT-V022-FUNC-OBSERVABILITY-003 FR-038 — Observability
UAT-V022-FUNC-OBSERVABILITY-004 FR-038 — Observability
UAT-V022-FUNC-AUDITABILITY-001 FR-038 — Auditability

---

Appendix A — Licensing UAT Reuse Strategy

After FR-038, every future feature requires only 2 license tests:

```
UAT-<FEATURE>-LIC-001: Entitlement present → PASS
UAT-<FEATURE>-LIC-002: Entitlement absent → DENY
```

Example — FR-039 Parallelism:

· UAT-PAR-LIC-001: Entitlement present → PASS
· UAT-PAR-LIC-002: Entitlement absent → DENY

No need to re-test the entire license framework. FR-038 centralizes licensing UAT and makes future feature licensing nearly free.
