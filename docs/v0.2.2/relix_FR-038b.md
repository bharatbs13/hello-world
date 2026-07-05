# FR-038B — License Lifecycle Management

## Status
Approved

## Target Product Version
v0.2.2 (or later)

## Objective
Provide lifecycle management for product licenses and feature entitlements. The framework governs how license state evolves over time through renewal, replacement, upgrades, downgrades, suspensions, and revocations.

The framework enables license state transitions without requiring modification to authorization logic or capability implementations.

---

## Scope

### Owns
- license renewal
- license replacement
- entitlement refresh
- feature upgrade
- feature downgrade
- entitlement add/remove
- entitlement expiry extension
- license suspension
- license reactivation
- license revocation
- license versioning
- lifecycle audit events
- lifecycle state transitions

### Does Not Own
- product license validation (see FR-038A)
- capability authorization decisions (see FR-038A)
- billing or invoicing
- payment processing
- subscription management
- SaaS control plane
- commercial integration (see FR-039)
- capability implementation
- execution state or frozen execution policies

---

## Lifecycle Model

### State Evolution

```
Current License State
         ↓
Lifecycle Event
         ↓
New License State
         ↓
Validate New State
         ↓
Replace Current License State
         ↓
Emit Lifecycle Event
         ↓
Future Authorizations Use New State (FR-038A)
```

**License Status Transitions:**
```
ACTIVE → GRACE (automatic expiry)
ACTIVE → REVOKED (explicit)
ACTIVE → SUSPENDED (explicit)
GRACE → EXPIRED (automatic)
GRACE → ACTIVE (renewal during grace)
GRACE → REVOKED (explicit)
GRACE → SUSPENDED (explicit)
EXPIRED → ACTIVE (renewal after expiry)
EXPIRED → REVOKED (explicit)
SUSPENDED → ACTIVE (reactivation)
SUSPENDED → REVOKED (explicit)
REVOKED → (terminal state)
```

---

## Lifecycle Operations

### License Renewal

Extend product license validity.

**Before:**
```
status: ACTIVE
product_expiry: 2027-12-31
entitlements:
  - migration: valid
```

**After:**
```
status: ACTIVE
product_expiry: 2028-12-31
entitlements:
  - migration: valid
  - parallelism: valid
```

**Validation Rules:**
- New expiry must satisfy lifecycle transition policy (not hardcoded to "after current")
- All existing entitlements must remain valid or be explicitly addressed
- Renewal can occur from ACTIVE, GRACE, or EXPIRED states

---

### Feature Upgrade

Add new entitlements to existing license.

**Before:**
```
entitlements:
  - migration
  - parallelism
```

**After:**
```
entitlements:
  - migration
  - parallelism
  - agent_assistant
```

**Validation Rules:**
- No duplicate entitlement IDs
- No existing entitlement removed unless explicitly downgraded
- New entitlement may have independent expiry

---

### Feature Downgrade

Remove entitlements from existing license.

**Before:**
```
entitlements:
  - migration
  - parallelism
  - agent_assistant
```

**After:**
```
entitlements:
  - migration
  - parallelism
```

**Rules:**
- FR-038B does not check execution state
- FR-038A frozen execution policy determines runtime impact
- New executions are denied for removed capabilities

---

### Entitlement Add/Remove

Modify individual entitlement properties.

**Before:**
```
entitlements:
  - capability_id: parallelism
    expiry: 2027-06-30
```

**After:**
```
entitlements:
  - capability_id: parallelism
    expiry: 2028-06-30
```

---

### Entitlement Expiry Extension

Extend validity period for specific entitlements.

**Before:**
```
entitlements:
  - capability_id: topology_optimization
    expiry: 2027-03-31
  - capability_id: advanced_reconciliation
    expiry: 2027-06-30
```

**After:**
```
entitlements:
  - capability_id: topology_optimization
    expiry: 2027-09-30
  - capability_id: advanced_reconciliation
    expiry: 2027-06-30
```

---

### License Suspension

Temporarily disable license.

**Use Cases:**
- Payment processing delay (FR-039 integration)
- Contract compliance investigation
- Emergency operational pause

**Before:**
```
status: ACTIVE
```

**After:**
```
status: SUSPENDED
```

**Rules:**
- Suspension is reversible via REACTIVATE
- Suspension does not affect frozen executions (FR-038A policy)
- New authorization requests are denied

---

### License Reactivation

Restore suspended license.

**Before:**
```
status: SUSPENDED
```

**After:**
```
status: ACTIVE
```

**Validation Rules:**
- License must be in SUSPENDED state
- All entitlements must still be valid
- Reactivation may require re-validation of commercial terms (FR-039)

---

### License Revocation

Permanently terminate license.

**Before:**
```
status: ACTIVE | GRACE | EXPIRED | SUSPENDED
```

**After:**
```
status: REVOKED
```

**Use Cases:**
- Contract termination
- Fraud detection
- Emergency kill switch
- Commercial dispute

**Rules:**
- REVOKED is a terminal state
- No reactivation from REVOKED
- All authorization requests denied by FR-038A
- REVOKED does not terminate frozen executions (FR-038A policy)

---

### License Replacement

Replace entire license state.

**Use Cases:**
- Migration from trial to subscription
- Migration from subscription to enterprise
- License version upgrade
- Emergency license override

**Validation Rules:**
- New license must be structurally valid
- All entitlements must be valid or explicitly removed
- License ID may change
- Status may change according to transition rules

---

## License Versioning

The framework shall support versioning of license state.

**Versioning Model:**
```
License
├── license_id
├── version
├── previous_version
├── updated_at
├── update_type
└── update_reason
```

**Update Types:**
- `RENEWAL`
- `UPGRADE`
- `DOWNGRADE`
- `ENTITLEMENT_ADD`
- `ENTITLEMENT_REMOVE`
- `ENTITLEMENT_EXTEND`
- `REPLACEMENT`
- `SUSPENSION`
- `REACTIVATION`
- `REVOCATION`

---

## State Validation

Before applying any lifecycle change, the framework shall validate:

1. **Structural Validity**
   - All required fields present
   - Entitlements properly formatted
   - No duplicate entitlement IDs

2. **Semantic Validity**
   - Product expiry is valid
   - Entitlement expiry (if present) is valid
   - Grace period is valid if specified
   - Status transition is allowed

3. **Transition Validity**
   - New state is consistent with previous state
   - Status transition follows allowed state machine
   - No invalid transitions

4. **Commercial Policy (FR-039 integration)**
   - Policy validation delegated to FR-039
   - FR-038B applies validated state changes

---

## Observability

The framework shall emit license lifecycle events.

**Events:**
- `LICENSE_RENEWAL_STARTED`
- `LICENSE_RENEWAL_COMPLETED`
- `LICENSE_RENEWAL_FAILED`
- `LICENSE_UPGRADE_STARTED`
- `LICENSE_UPGRADE_COMPLETED`
- `LICENSE_DOWNGRADE_STARTED`
- `LICENSE_DOWNGRADE_COMPLETED`
- `ENTITLEMENT_ADDED`
- `ENTITLEMENT_REMOVED`
- `ENTITLEMENT_EXTENDED`
- `LICENSE_SUSPENDED`
- `LICENSE_REACTIVATED`
- `LICENSE_REVOKED`
- `LICENSE_REPLACED`
- `LICENSE_VERSION_UPDATED`

---

## Audit Metadata

License lifecycle decisions shall be traceable.

**Audit metadata may include:**
- `license_id`
- `previous_version`
- `new_version`
- `update_type`
- `update_reason`
- `changes` (list of changes applied)
- `previous_status`
- `new_status`
- `previous_expiry`
- `new_expiry`
- `previous_entitlements` (hash or list)
- `new_entitlements` (hash or list)
- `applied_at`
- `applied_by`
- `validation_result`
- `commercial_policy_check` (FR-039 reference)

---

## Integration with FR-038A

**Lifecycle updates:**
1. FR-038B updates license state
2. FR-038A reads current license state
3. FR-038A authorizes future requests based on new state
4. Frozen executions remain protected by FR-038A policy

**Decoupling:**
- FR-038B does not check execution state
- FR-038B does not terminate executions
- FR-038A determines runtime impact of state changes
- FR-038B is not aware of frozen executions

**No coordination required:**
- FR-038B does not need to notify FR-038A of changes
- FR-038A always reads current state
- State updates are atomic and versioned

---

## Integration with FR-039

**Commercial Integration Flow:**
```
Billing / SaaS System
         ↓
FR-039 Commercial Integration Hooks
         ↓
FR-038B Lifecycle Operations
         ↓
FR-038A Authorization
```

**FR-039 Responsibilities:**
- Validate commercial policy
- Determine if renewal is approved
- Trigger suspension for payment failures
- Trigger reactivation for payment resolution
- Validate upgrade/downgrade commercial terms

**FR-038B Responsibilities:**
- Apply validated state changes
- Version license state
- Emit lifecycle events
- Maintain audit trail

---

## Acceptance Criteria

| AC# | Description |
|-----|-------------|
| AC1 | Relix shall support product license renewal with extended expiry. |
| AC2 | Relix shall support feature upgrades by adding entitlements. |
| AC3 | Relix shall support feature downgrades by removing entitlements. |
| AC4 | Relix shall support entitlement addition without modifying capability definitions. |
| AC5 | Relix shall support entitlement removal without modifying capability definitions. |
| AC6 | Relix shall support entitlement expiry extension. |
| AC7 | Relix shall support complete license replacement. |
| AC8 | Relix shall validate new license state before applying changes. |
| AC9 | Relix shall emit lifecycle governance events for all license state changes. |
| AC10 | Relix shall maintain audit trail of license state transitions. |
| AC11 | License state changes shall not disrupt previously frozen execution plans (delegated to FR-038A). |
| AC12 | License state updates shall be atomic and versioned. |
| AC13 | Entitlement assignment changes shall not require modification to capability implementations. |
| AC14 | Relix shall support license suspension with reversible reactivation. |
| AC15 | Relix shall support license revocation as a terminal state. |
| AC16 | FR-038B shall not check execution state or terminate frozen executions. |
| AC17 | FR-038B shall support renewal from ACTIVE, GRACE, and EXPIRED states. |
| AC18 | License status shall support ACTIVE, GRACE, EXPIRED, SUSPENDED, and REVOKED states. |

---

## Design Rule

License lifecycle management is distinct from runtime authorization.

FR-038B manages state changes over time. FR-038A evaluates state at runtime.

FR-038B does not interpret capability semantics or enforce authorization. It only manages license state transitions.

FR-038B does not check execution state. Frozen execution protection is owned by FR-038A.

Commercial integrations (FR-039) feed into FR-038B. Authorization decisions flow from FR-038A.

The separation enables:
- Independent evolution of lifecycle and authorization logic
- Multi-tenant licensing without redesign
- Per-solution licensing models
- Enterprise deployment scenarios

---

## Appendix A — Supported Lifecycle Scenarios

This framework supports the following lifecycle scenarios without architectural change:

| Scenario | Description | FR-038B Operation |
|----------|-------------|-------------------|
| Annual renewal | Extend product license expiry | License Renewal |
| Add-on purchase | Customer buys new capability | Feature Upgrade |
| Add-on expiry | Feature entitlement expires naturally | Entitlement Expiry Extension or Removal |
| Trial conversion | Trial license → paid subscription | License Replacement |
| Enterprise upgrade | Standard → enterprise license | License Replacement |
| Feature sunset | Capability discontinued | Feature Downgrade |
| Capability rollback | Re-add removed feature | Feature Upgrade |
| Grace extension | Extend grace period | License Replacement |
| Entitlement extension | Extend specific feature expiry | Entitlement Expiry Extension |
| Payment failure | Suspend license for non-payment | License Suspension |
| Payment resolution | Reactivate after payment | License Reactivation |
| Contract termination | Permanently revoke license | License Revocation |
| Emergency kill switch | Immediate termination | License Revocation |
| Contract investigation | Temporary suspension | License Suspension |
| Emergency override | Replace invalid license | License Replacement |

---
