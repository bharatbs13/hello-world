# FR-038 — License Governance Framework

## Status
Draft

## Target Product Version
v0.2.2

## Objective
Provide platform-level license governance through license validation, entitlement enforcement, capability authorization, expiry management, and license observability.

The framework enables Relix capabilities to be governed through license entitlements without introducing capability-specific licensing logic.

The framework shall support future capability licensing without requiring modification to the licensing framework implementation.

---

## Scope

### Owns
- license definition
- license validation
- entitlement validation
- capability authorization
- expiry validation
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
license validation
        ↓
entitlement validation
        ↓
ALLOW | DENY
```

The framework shall not interpret capability semantics.

---

## License Model
A license shall support:
- license identifier
- customer identifier
- license type
- issue date
- expiry date
- entitlement set
- grace period policy
- license metadata

Supported license types may include:
- trial
- subscription
- enterprise
- perpetual

---

## Expiry Management
The framework shall validate license expiry.

The framework shall support configurable expiry policies.

Supported actions may include:
- warning
- grace period
- plan-freeze prevention
- capability authorization denial

---

## Grace Period
The framework shall support configurable grace periods.

Grace period behavior shall be observable and auditable.

---

## Frozen Execution Protection
License validation shall occur before execution-plan freeze.

The framework shall not terminate running executions solely because a license expires after execution-plan freeze.

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
- license identifier
- capability identifier
- entitlement evaluated
- validation result
- evaluation timestamp

---

## Acceptance Criteria

| AC# | Description |
|-----|-------------|
| AC1 | Relix shall support license validation. |
| AC2 | Relix shall support entitlement validation. |
| AC3 | Relix shall support capability authorization. |
| AC4 | Relix shall support expiry validation. |
| AC5 | Relix shall support configurable grace periods. |
| AC6 | Relix shall emit license governance events. |
| AC7 | Relix shall preserve execution stability for previously frozen execution plans. |
| AC8 | Relix shall support future capability authorization without modification to the licensing framework implementation. |
| AC9 | Capabilities shall declare licensing requirements through platform-defined entitlement contracts. |
| AC10 | Entitlement assignment changes shall not require modification to capability implementations. |

---

## Design Rule
Licensing is a platform governance capability.

Capabilities request authorization through declared entitlement contracts.

The licensing framework shall remain independent of capability implementations and shall not contain feature-specific behavior.
