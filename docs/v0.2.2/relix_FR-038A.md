# FR-038A — License Authorization Framework

## Status
Approved

## Target Product Version
v0.2.2

## Objective
Provide runtime license authorization for Relix capabilities. The framework governs whether a requested capability can execute based on product license validation, feature entitlement validation, and grace period enforcement.

The framework enables capability authorization without introducing capability-specific licensing logic.

---

## Scope

### Owns
- product license validation
- capability declaration evaluation
- feature entitlement validation
- capability authorization decisions
- product expiry precedence
- entitlement expiry validation
- grace period enforcement
- frozen execution protection
- license governance events
- authorization audit metadata

### Does Not Own
- license renewal
- license replacement
- entitlement refresh or updates
- feature upgrades/downgrades
- entitlement add/remove
- billing or payment processing
- subscription management
- SaaS control plane
- capability implementation
- workflow orchestration
- execution planning
- checkpointing
- reconciliation

---

## Licensing Model

### Two-Level Authorization

```
Product License
       ↓
Feature Entitlement
       ↓
Authorization Decision
```

**Level 1 — Product License:** Governs overall product validity. Product expiry supersedes all feature entitlements.

**Level 2 — Feature Entitlements:** Govern individual capability access. Feature entitlements may have independent expiry. If entitlement expiry is absent, the entitlement inherits product license validity.

---

## Authorization Flow

```
Requested Capability
        ↓
license_required?
        ↓
(false) → ALLOW (free capability)
        ↓
(true):
Product License Check
        ↓
Valid?
   yes ↓        no
Entitlement   Grace Active?
   Check         ↓
              yes → continue with warning
              no  → DENY
        ↓
Entitlement Exists?
        ↓
(no) → DENY
        ↓
(yes):
Entitlement Valid?
        ↓
(no) → DENY
        ↓
(yes) → ALLOW
```

**Product License States:**
- `ACTIVE` — License is valid
- `GRACE` — License expired but within grace period
- `EXPIRED` — License expired and grace period elapsed
- `REVOKED` — License explicitly revoked

**Rules:**
- Product-level license expiry takes precedence over capability-level entitlement validity
- Free capabilities bypass license and entitlement checks entirely
- Grace period applies at product license level only
- Grace check must occur before DENY for expired licenses

---

## Principles

### Capability-Agnostic Licensing
- The licensing framework shall remain independent of capability implementations
- The licensing framework shall not contain capability-specific logic

**Examples of capabilities that require no framework changes:**
- parallelism
- distributed_execution
- topology_optimization
- advanced_reconciliation

### Capability-Entitlement Separation
- Capability definitions declare licensing requirements
- Entitlements are stored and managed within the license, not within capability definitions

**Example:**
```
CapabilityDefinition:
  capability_id: internal_data_plane_parallelism
  license_required: true
  required_entitlement: internal_data_plane_parallelism

License:
  status: ACTIVE
  entitlements:
  - capability_id: internal_data_plane_parallelism
    expiry: 2027-06-30
```

---

## Object Model

### License
```
License
├── license_id
├── customer_id
├── license_type
├── status          // ACTIVE | GRACE | EXPIRED | REVOKED
├── issue_date
├── expiry
├── grace_period
├── metadata
└── entitlements[]
```

### Entitlement
```
Entitlement
├── capability_id
├── expiry (optional)
└── metadata
```

### Capability Definition
```
CapabilityDefinition
├── capability_id
├── license_required
├── required_entitlement
└── metadata
```

---

## Authorization Function

```
check_authorization(capability_id):
    1. Check license_required from CapabilityDefinition
    2. If false, return ALLOW
    3. Check License.status
    4. If status == REVOKED, return DENY
    5. If status == EXPIRED, return DENY
    6. If status == GRACE, continue with warning
    7. If status == ACTIVE, continue
    8. Lookup entitlement by capability_id
    9. If not found, return DENY
    10. Validate entitlement expiry
    11. Return decision
```

---

## Examples

### Example 1 — All Valid
```
License.status: ACTIVE
Parallelism Entitlement: valid
→ ALLOW
```

### Example 2 — Feature Expired
```
License.status: ACTIVE
Parallelism Entitlement: expired
→ DENY Parallelism
→ ALLOW other entitled features
```

### Example 3 — Product Expired (No Grace)
```
License.status: EXPIRED
Parallelism Entitlement: valid
→ DENY everything
```

### Example 4 — Product in Grace Period
```
License.status: GRACE
Parallelism Entitlement: valid
→ ALLOW with warning
→ Emit LICENSE_GRACE_PERIOD_ENTERED
```

### Example 5 — Free Capability
```
Capability.license_required: false
→ ALLOW (no license or entitlement check)
```

### Example 6 — Entitlement Inherits Product Validity
```
License.status: ACTIVE (expires 2027-12-31)
Parallelism Entitlement: no expiry specified
→ Entitlement inherits product expiry (2027-12-31)
```

### Example 7 — License Revoked
```
License.status: REVOKED
Any capability requested
→ DENY everything
→ Emit LICENSE_REVOKED event
```

---

## Expiry Management

The framework shall validate:

1. Product license expiry (via License.status)
2. Feature entitlement expiry (when present)

**Precedence:** Product-level expiry shall take precedence over entitlement-level expiry.

**License Status Transitions:**
```
ACTIVE → GRACE (expiry reached, grace period active)
GRACE → EXPIRED (grace period elapsed)
ACTIVE → REVOKED (explicit revocation)
GRACE → REVOKED (explicit revocation)
EXPIRED → REVOKED (explicit revocation)
REVOKED → (terminal state)
```

---

## Grace Period

The framework shall support configurable grace periods at the product license level.

**Grace Period Behavior:**
- License.status transitions from ACTIVE → GRACE upon expiry
- During GRACE, authorization continues with warnings
- After grace period, License.status transitions to EXPIRED
- EXPIRED status denies all capability authorization

Grace period behavior shall be:
- Observable through governance events
- Auditable through audit metadata
- Configurable per license

---

## Frozen Execution Protection

License validation shall occur before execution-plan freeze.

The framework shall not terminate running executions solely because:
- A product license expires after execution-plan freeze
- A required entitlement expires after execution-plan freeze

Previously frozen execution plans shall remain executable according to configured policy.

**FR-038B** may remove entitlements. **FR-038A** frozen execution policy determines runtime impact. Lifecycle and execution remain decoupled.

---

## Capability Registry

Capabilities shall be registered with licensing metadata:

```
CapabilityRegistry
├── capability_id
├── license_required
├── required_entitlement
└── metadata
```

The licensing framework shall evaluate authorization using capability metadata from the registry.

**Architecture:**
```
Capability Registry
         +
License Registry
         ↓
Authorization Engine (FR-038A)
```

---

## Observability

The framework shall emit license governance events.

**Events:**
- `LICENSE_VALIDATION_STARTED`
- `LICENSE_VALIDATION_PASSED`
- `LICENSE_VALIDATION_FAILED`
- `LICENSE_EXPIRED`
- `LICENSE_GRACE_PERIOD_ENTERED`
- `LICENSE_ENTITLEMENT_DENIED`
- `LICENSE_REVOKED`

---

## Audit Metadata

License decisions shall be traceable.

**Audit metadata may include:**
- `license_id`
- `license_status`
- `capability_id`
- `entitlement_evaluated`
- `entitlement_expiry`
- `product_expiry`
- `license_required`
- `validation_result`
- `evaluation_timestamp`
- `grace_period_active`

---

## Acceptance Criteria

| AC# | Description |
|-----|-------------|
| AC1 | Relix shall support product-level license validation. |
| AC2 | Relix shall support capability-level entitlement validation. |
| AC3 | Relix shall support capability authorization decisions. |
| AC4 | Relix shall support expiry validation at both product and entitlement levels. |
| AC5 | Relix shall support configurable grace periods. |
| AC6 | Relix shall emit license governance events. |
| AC7 | Relix shall preserve execution stability for previously frozen execution plans when either product license or required entitlement expires after freeze. |
| AC8 | Relix shall support future capability authorization without modification to the licensing framework implementation. |
| AC9 | Capabilities shall declare licensing requirements through platform-defined entitlement contracts. |
| AC10 | Entitlement assignment changes shall not require modification to capability implementations. |
| AC11 | Product-level license expiry shall take precedence over capability-level entitlement validity. |
| AC12 | Feature entitlements may have independent expiry from the product license. If entitlement expiry is absent, the entitlement shall inherit product license validity. |
| AC13 | License status shall support ACTIVE, GRACE, EXPIRED, and REVOKED states. |
| AC14 | Grace period checks shall occur before denial for expired product licenses. |

---

## Design Rule

Licensing is a platform governance capability.

Capabilities request authorization through declared entitlement contracts.

The licensing framework shall remain independent of capability implementations and shall not contain feature-specific behavior.

Product license validity governs overall access. Feature entitlements govern individual capability access. Product expiry supersedes feature expiry. Free capabilities bypass license and entitlement checks.

The Capability Registry and License Registry are separate concerns, enabling multi-tenant and multi-product licensing without redesign.

---

## Appendix A — Supported Commercial Models

This framework supports the following commercial licensing models without architectural change:

| Model | Description |
|-------|-------------|
| Annual Product License | All features inherit product validity |
| Add-on Features | Independently expiring feature entitlements |
| Trial Features | Feature entitlements with short expiry within a valid product license |
| Enterprise Add-ons | Selectively purchased capabilities with independent expiry |
| Feature Packs | Bundled entitlements with shared expiry |
| Emergency Suspension | REVOKED status for contract violations |
| Grace Period Extensions | GRACE status with configurable duration |

---

