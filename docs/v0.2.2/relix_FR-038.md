
# FR-038 — License Governance Framework

## Status
Approved

## Target Product Version
v0.2.2

## Objective
Provide platform-level license governance through two-level licensing: product license validation and feature entitlement enforcement. The framework governs capability authorization, expiry management, grace period handling, and license observability.

The framework enables Relix capabilities to be governed through license entitlements without introducing capability-specific licensing logic.

The framework shall support future capability licensing without requiring modification to the licensing framework implementation.

---

## Scope

### Owns
- product license definition
- product license validation
- feature entitlement validation
- capability authorization
- expiry validation (product and entitlement level)
- grace period enforcement
- license lifecycle
- license observability
- license audit metadata
- capability entitlement contracts

### Does Not Own
- billing
- invoicing
- payment processing
- subscription management
- SaaS control plane
- usage reporting
- capability implementation
- workflow orchestration
- execution planning
- checkpointing
- reconciliation
- connector governance

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

### Authorization Logic

```

requested capability
↓
license_required?
↓
(false) → ALLOW (free capability)
↓
(true):
product license expired?
↓
(yes) → DENY (all capabilities)
↓
(no):
entitlement exists?
↓
(no) → DENY
↓
(yes):
entitlement expired?
↓
(yes) → DENY
↓
(no) → ALLOW

```

Product-level license expiry takes precedence over capability-level entitlement validity. Free capabilities bypass license and entitlement checks entirely.

---

## Principles

### Capability-Agnostic Licensing
The licensing framework shall remain independent of capability implementations.

The licensing framework shall not contain capability-specific logic.

**Examples:**
- parallelism
- distributed_execution
- topology_optimization
- advanced_reconciliation

shall not require modifications to the licensing framework.

### Capability-Entitlement Separation
Capability definitions shall declare licensing requirements. Entitlements shall be stored and managed within the license, not within capability definitions.

```

Capability:
id: internal_data_plane_parallelism
license_required: true
required_entitlement: internal_data_plane_parallelism

License:
entitlements:
- capability_id: internal_data_plane_parallelism
expiry: 2027-06-30

```

Capabilities shall not store entitled customer lists. Entitlements are license properties, not capability properties.

---

## Capability Declaration
Capabilities may declare:
- capability_id
- required_entitlement
- license_required

The licensing framework shall evaluate authorization using capability metadata.

---

## Authorization Model
The framework shall evaluate:

```

requested capability
↓
license_required check
↓
(if false) → ALLOW
↓
product license validation
↓
grace policy evaluation
↓
entitlement lookup
↓
entitlement expiry validation
↓
ALLOW | DENY

```

The framework shall not interpret capability semantics.

---

## License Model

### Product License
A product license shall support:
- license_id
- customer_id
- license_type
- issue_date
- expiry_date
- grace_period
- metadata

Supported license types may include:
- trial
- subscription
- enterprise
- perpetual

### Feature Entitlement
An entitlement shall support:
- capability_id
- expiry (optional; inherits product licence validity if absent)
- metadata

Feature entitlement expiry is optional. If entitlement expiry is absent, the entitlement inherits product license validity.

---

## Object Model

```

License
├── license_id
├── customer_id
├── license_type
├── issue_date
├── expiry
├── grace_period
├── metadata
└── entitlements[]
Entitlement
├── capability_id
├── expiry (optional)
└── metadata

```

### Authorization Function

```

check_authorization(capability_id):
1. Check license_required
2. If false, return ALLOW
3. Validate product license
4. Validate grace policy
5. Lookup entitlement
6. Validate entitlement expiry
7. Return decision

```

---

## Examples

### Example 1 — All Valid
```

Product License: valid
Parallelism Entitlement: valid
→ ALLOW

```

### Example 2 — Feature Expired
```

Product License: valid
Parallelism Entitlement: expired
→ DENY Parallelism
→ ALLOW other entitled features

```

### Example 3 — Product Expired
```

Product License: expired
Parallelism Entitlement: valid
→ DENY everything

```
Feature expiry becomes irrelevant when product license is expired.

### Example 4 — Free Capability
```

Capability: topology_optimization
license_required: false
→ ALLOW (no license or entitlement check)

```

### Example 5 — Entitlement Inherits Product Validity
```

Product License: valid (expires 2027-12-31)
Parallelism Entitlement: no expiry specified
→ Entitlement inherits product expiry (2027-12-31)

```

---

## Expiry Management
The framework shall validate:

1. Product license expiry
2. Feature entitlement expiry (when present)

The framework shall support configurable expiry policies.

Supported actions may include:
- warning
- grace period
- plan-freeze prevention
- capability authorization denial

Product-level expiry shall take precedence over entitlement-level expiry.

---

## Grace Period
The framework shall support configurable grace periods.

Grace period behavior shall be observable and auditable.

Grace period applies at the product license level.

---

## Frozen Execution Protection
License validation shall occur before execution-plan freeze.

The framework shall not terminate running executions solely because:
- a product license expires after execution-plan freeze
- a required entitlement expires after execution-plan freeze

Previously frozen execution plans shall remain executable according to configured policy.

---

## Capability Entitlements
Capabilities may declare required entitlements.

**Example:**
```

capability_id:
internal_data_plane_parallelism

required_entitlement:
internal_data_plane_parallelism

```

Entitlements may have independent expiry:
```

entitlements:

· capability_id: internal_data_plane_parallelism
  expiry: 2027-06-30
· capability_id: topology_optimization
  expiry: 2027-03-31

```

Entitlements may inherit product license validity:
```

entitlements:

· capability_id: advanced_reconciliation
  no expiry — inherits product license validity

```

The entitlement assignment is product policy and may change through future change requests.

The licensing framework shall remain unchanged when entitlement assignments change.

---

## Observability
The framework shall emit license governance events.

**Examples:**
- LICENSE_VALIDATION_STARTED
- LICENSE_VALIDATION_PASSED
- LICENSE_VALIDATION_FAILED
- LICENSE_EXPIRED
- LICENSE_GRACE_PERIOD_ENTERED
- LICENSE_ENTITLEMENT_DENIED

---

## Audit Metadata
License decisions shall be traceable.

Audit metadata may include:
- license_id
- capability_id
- entitlement evaluated
- entitlement expiry
- product expiry
- license_required
- validation result
- evaluation timestamp

---

## Acceptance Criteria

| AC# | Description |
|-----|-------------|
| AC1 | Relix shall support product-level license validation. |
| AC2 | Relix shall support capability-level entitlement validation. |
| AC3 | Relix shall support capability authorization. |
| AC4 | Relix shall support expiry validation at both product and entitlement levels. |
| AC5 | Relix shall support configurable grace periods. |
| AC6 | Relix shall emit license governance events. |
| AC7 | Relix shall preserve execution stability for previously frozen execution plans when either product license or required entitlement expires after freeze. |
| AC8 | Relix shall support future capability authorization without modification to the licensing framework implementation. |
| AC9 | Capabilities shall declare licensing requirements through platform-defined entitlement contracts. |
| AC10 | Entitlement assignment changes shall not require modification to capability implementations. |
| AC11 | Product-level license expiry shall take precedence over capability-level entitlement validity. |
| AC12 | Feature entitlements may have independent expiry from the product license. If entitlement expiry is absent, the entitlement shall inherit product license validity. |

---

## Design Rule
Licensing is a platform governance capability.

Capabilities request authorization through declared entitlement contracts.

The licensing framework shall remain independent of capability implementations and shall not contain feature-specific behavior.

Product license validity governs overall access. Feature entitlements govern individual capability access. Product expiry supersedes feature expiry. Free capabilities bypass license and entitlement checks.

Entitlements are stored in the license. Capability definitions declare requirements. Capabilities do not store entitlement assignments or customer lists.

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