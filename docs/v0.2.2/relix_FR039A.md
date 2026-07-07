# FR-039A — SaaS Commercial Contract Framework

## Status
Approved

## Target Product Version
v0.2.2 (or later)

## Objective
Provide a commercial contract framework that defines what a customer is entitled to consume within the Relix SaaS platform. The framework shall model subscription plans, purchased solutions, feature entitlements, usage limits, SLA tiers, and tenant commercial status.

The framework shall translate commercial contract state into license lifecycle updates for FR-038B.

The objective is commercial-readiness, not payment processing or billing implementation.

---

## Scope

### Owns
- tenant commercial account model
- subscription plan model
- purchased solutions
- purchased capabilities
- feature entitlement mapping
- usage limits (data, executions, concurrency)
- SLA tier definition
- prepaid minimum reserve amount policy (contractual requirement)
- tenant commercial status (ACTIVE, SUSPENDED, BLOCKED, BLACKLISTED)
- contract state (valid_from, valid_until)
- commercial state → FR-038B trigger
- contract audit metadata

### Does Not Own
- license authorization (see FR-038A)
- license lifecycle state changes (see FR-038B)
- usage metering and aggregation (see FR-039B)
- estimated billing calculation (see FR-039B)
- current prepaid reserve balance (see FR-039B)
- usage DB interface (see FR-039B)
- billing DB interface (see FR-039B)
- payment gateway integration (see FR-039B)
- prepaid balance check (see FR-039B)
- invoice generation
- payment collection
- taxation
- pricing engine
- discount calculation
- contract negotiation

---

## Relationship to FR-038A, FR-038B, and FR-039B

FR-039A defines commercial contract state.

FR-038B consumes commercial state to create/update license state.

FR-038A authorizes runtime requests.

FR-039B handles usage, billing, and payment integration contracts.

```

Customer Subscription / Contract
|
v
FR-039A — Commercial Contract Framework
|
v
FR-038B — License Lifecycle Management
|
v
FR-038A — License Authorization
|
v
FR-040 — Resource Planning
|
v
FR-041 — Connectivity Validation
|
v
Execution
|
v
FR-039B — Usage, Billing, Payment Integration

```

FR-039A shall not override FR-038A authorization logic.

FR-039A shall not directly modify license state; it shall trigger FR-038B to apply changes.

---

## Principles

### Commercial Contract as Source of Truth
The commercial contract shall be the source of truth for what a customer has purchased.

FR-038B shall derive license state from the commercial contract.

License state shall not be manually modified without corresponding contract change.

### Separation from Runtime Authorization
Commercial contract defines entitlement.

License authorization evaluates entitlement at runtime.

These are separate concerns separated by FR-038B.

### Separation from Billing/Payment Operations
FR-039A defines what is purchased and commercial status.

FR-039B handles usage, estimation, payment integration, and current balance.

Payment collection, invoicing, and taxation are out of scope for this FR.

### Commercial Status Enforced via License Lifecycle
FR-039A commercial status (BLOCKED, BLACKLISTED) shall result in license suspension/revocation via FR-038B.

Runtime enforcement is handled by FR-038A reading license state.

---

## Commercial Contract Model

### Tenant Commercial Account
```

TenantCommercialAccount:
tenant_id: string
commercial_status: ACTIVE | SUSPENDED | BLOCKED | BLACKLISTED
status_reason: optional string
contract_id: string
plan_id: string
valid_from: timestamp
valid_until: timestamp
billing_model: subscription | usage_based | hybrid | perpetual
prepaid_minimum_reserve_amount: optional decimal   # contractual requirement only
solutions: list of string
features: list of string
usage_limits: UsageLimits
sla_tier: standard | premium
metadata: object

```

Note: `current_reserve_balance` is owned by FR-039B (billing state).

### Commercial Status Definitions
| Status | Meaning | Effect on License |
|--------|---------|-------------------|
| ACTIVE | Contract valid, payments up-to-date | License active |
| SUSPENDED | Temporary hold (payment issue, compliance review) | License suspended |
| BLOCKED | Contract violation, service blocked | License revoked |
| BLACKLISTED | Permanent denial, fraud or serious breach | License revoked, no reactivation |

### Usage Limits
```

UsageLimits:
max_data_gb_month: optional integer
max_executions_month: optional integer
max_concurrent_jobs: optional integer
max_parallelism_level: optional integer
max_dwe_nodes: optional integer
overage_policy: block | allow_with_warning | allow_with_charge

```

### Subscription Plan
```

SubscriptionPlan:
plan_id: string
plan_name: string
billing_model: subscription | usage_based | hybrid | perpetual
default_solutions: list of string
default_features: list of string
default_usage_limits: UsageLimits
default_sla_tier: standard | premium
default_prepaid_minimum_reserve_amount: optional decimal
metadata: object

```

---

## Feature Entitlement Mapping

FR-039A shall map commercial features to license entitlements.

**Mapping Examples:**
```

Commercial Feature → License Entitlement

---

dwe                 → dwe
parallelism         → internal_parallelism
advanced_recon      → advanced_reconciliation
agent_assistant     → agent_assistant

```

**Solution to Feature Mapping:**
```

Solution: migration
Required Features:
- dwe (if data > 1TB)
- parallelism (if SLA < 60min)

```

FR-039A shall produce a set of entitlements to be applied to the license.

---

## Contract Lifecycle

### Contract States (Commercial Status)
```

ACTIVE     → Contract valid, entitlements active
SUSPENDED  → Contract suspended (payment issue, compliance)
BLOCKED    → Contract blocked (violation)
BLACKLISTED→ Permanent denial
EXPIRED    → Contract expired (valid_until passed)

```

### Lifecycle Transitions
```

Contract Created → ACTIVE
Contract Renewed → ACTIVE (valid_until extended)
Contract Expired → EXPIRED → triggers SUSPENDED/BLOCKED based on policy
Contract Suspended → SUSPENDED
Contract Reactivated → ACTIVE
Contract Blocked → BLOCKED
Contract Blacklisted → BLACKLISTED
Plan Upgraded → ACTIVE (entitlements added)
Plan Downgraded → ACTIVE (entitlements removed)

```

---

## Contract → License Translation

FR-039A shall translate commercial contract state into license update instructions.

**Translation Logic:**
```

For each solution in contract.solutions:
For each feature in solution.features:
Add entitlement: feature

For each feature in contract.features:
Add entitlement: feature

Set license.expiry = contract.valid_until
Set license.license_type = contract.billing_model
Set license.status based on commercial_status:
ACTIVE → ACTIVE
SUSPENDED → SUSPENDED
BLOCKED → REVOKED
BLACKLISTED → REVOKED (with permanent flag)

```

**Output (to FR-038B):**
```

LicenseUpdateRequest:
tenant_id: string
license_id: string (or generate)
expiry: timestamp
license_type: subscription | usage_based | hybrid | perpetual
entitlements: list of Entitlement
status: ACTIVE | SUSPENDED | REVOKED
source: commercial_contract
contract_id: string
commercial_status: string (for audit)

```

---

## Commercial Contract Examples

### Example 1: Enterprise Subscription (ACTIVE)
```json
{
  "tenant_id": "bank_001",
  "commercial_status": "ACTIVE",
  "contract_id": "CT-2027-001",
  "plan_id": "enterprise",
  "valid_from": "2027-01-01T00:00:00Z",
  "valid_until": "2027-12-31T23:59:59Z",
  "billing_model": "subscription",
  "prepaid_minimum_reserve_amount": 5000.00,
  "solutions": ["migration", "backup", "reconciliation"],
  "features": ["dwe", "internal_parallelism", "advanced_reconciliation"],
  "usage_limits": {
    "max_data_gb_month": 10000,
    "max_executions_month": 500,
    "max_concurrent_jobs": 10,
    "max_parallelism_level": 16,
    "overage_policy": "allow_with_warning"
  },
  "sla_tier": "premium"
}
```

License Update:

```json
{
  "tenant_id": "bank_001",
  "expiry": "2027-12-31T23:59:59Z",
  "license_type": "subscription",
  "status": "ACTIVE",
  "entitlements": [
    {"capability_id": "migration"},
    {"capability_id": "backup"},
    {"capability_id": "reconciliation"},
    {"capability_id": "dwe"},
    {"capability_id": "internal_parallelism"},
    {"capability_id": "advanced_reconciliation"}
  ],
  "source": "commercial_contract",
  "contract_id": "CT-2027-001"
}
```

Example 2: Trial Subscription

```json
{
  "tenant_id": "startup_002",
  "commercial_status": "ACTIVE",
  "contract_id": "CT-2027-002",
  "plan_id": "trial",
  "valid_from": "2027-01-15T00:00:00Z",
  "valid_until": "2027-02-15T23:59:59Z",
  "billing_model": "subscription",
  "prepaid_minimum_reserve_amount": 0,
  "solutions": ["migration"],
  "features": ["internal_parallelism"],
  "usage_limits": {
    "max_data_gb_month": 100,
    "max_executions_month": 10,
    "max_concurrent_jobs": 2,
    "overage_policy": "block"
  },
  "sla_tier": "standard"
}
```

Example 3: Contract Suspended (Payment Issue)

```json
{
  "tenant_id": "startup_002",
  "commercial_status": "SUSPENDED",
  "status_reason": "payment_failed",
  "contract_id": "CT-2027-002",
  "plan_id": "trial",
  "valid_from": "2027-01-15T00:00:00Z",
  "valid_until": "2027-02-15T23:59:59Z",
  "billing_model": "subscription",
  "solutions": [],
  "features": [],
  "usage_limits": {},
  "sla_tier": "standard"
}
```

License Update:

```json
{
  "tenant_id": "startup_002",
  "status": "SUSPENDED",
  "entitlements": [],
  "source": "commercial_contract",
  "contract_id": "CT-2027-002"
}
```

Example 4: Tenant BLACKLISTED

```json
{
  "tenant_id": "fraud_003",
  "commercial_status": "BLACKLISTED",
  "status_reason": "fraud_detected",
  "contract_id": "CT-2027-003",
  "plan_id": "enterprise",
  "valid_from": "2027-01-01T00:00:00Z",
  "valid_until": "2027-12-31T23:59:59Z",
  "billing_model": "subscription",
  "solutions": [],
  "features": [],
  "usage_limits": {},
  "sla_tier": "standard"
}
```

License Update:

```json
{
  "tenant_id": "fraud_003",
  "status": "REVOKED",
  "permanent": true,
  "entitlements": [],
  "source": "commercial_contract",
  "contract_id": "CT-2027-003"
}
```

---

Observability

FR-039A shall emit commercial contract events.

Events:

· COMMERCIAL_CONTRACT_LOADED
· COMMERCIAL_CONTRACT_ACTIVATED
· COMMERCIAL_CONTRACT_EXPIRED
· COMMERCIAL_CONTRACT_SUSPENDED
· COMMERCIAL_CONTRACT_REACTIVATED
· COMMERCIAL_CONTRACT_BLOCKED
· COMMERCIAL_CONTRACT_BLACKLISTED
· COMMERCIAL_CONTRACT_UPGRADED
· COMMERCIAL_CONTRACT_DOWNGRADED
· COMMERCIAL_ENTITLEMENT_MAPPING_GENERATED
· COMMERCIAL_LICENSE_UPDATE_TRIGGERED

---

Audit Metadata

Commercial contract decisions shall be auditable.

Audit metadata may include:

· contract_id
· tenant_id
· commercial_status
· status_reason
· plan_id
· valid_from
· valid_until
· solutions
· features
· usage_limits
· sla_tier
· prepaid_minimum_reserve_amount
· license_update_triggered
· event_timestamp

---

Failure Handling

Commercial contract failures shall fail safely.

If contract cannot be loaded:

· Actionable error shall be emitted
· No license update shall be applied
· Existing license state shall remain unchanged
· Tenant should be notified via commercial ops

If contract mapping fails:

· Error shall be emitted
· Entitlement set shall be incomplete
· License update shall be blocked
· Human intervention required

If commercial_status is BLACKLISTED:

· License update shall set REVOKED with permanent flag
· No reactivation allowed

---

Acceptance Criteria

AC# Description
AC1 Relix shall define a tenant commercial account model.
AC2 Relix shall define a subscription plan model.
AC3 Relix shall define usage limits.
AC4 Relix shall define SLA tiers.
AC5 Relix shall support commercial statuses: ACTIVE, SUSPENDED, BLOCKED, BLACKLISTED.
AC6 Relix shall map commercial features to license entitlements.
AC7 Relix shall trigger FR-038B license updates from contract state.
AC8 Relix shall support prepaid minimum reserve amount policy (contractual).
AC9 Relix shall emit commercial contract events.
AC10 Relix shall maintain audit trail of commercial contract changes.
AC11 FR-039A shall not implement payment processing, invoicing, or taxation.
AC12 FR-039A shall not override FR-038A authorization logic.
AC13 Contract failures shall not corrupt existing license state.
AC14 BLACKLISTED status shall trigger permanent license revocation.

---

Design Rule

Commercial contract is the source of truth for what a customer has purchased.

FR-039A defines commercial state.

FR-038B consumes commercial state to generate license state.

FR-038A evaluates license state at runtime.

FR-039A shall not directly modify license state; it shall trigger FR-038B to apply changes.

FR-039A shall remain independent of payment processing, invoicing, and taxation.

Tenant commercial status (BLOCKED, BLACKLISTED) is enforced through license lifecycle, not direct runtime checks.

The current reserve balance is a billing/payment concern and is owned by FR-039B.

---

Appendix A — Integration Architecture

Component Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                  Commercial / Subscription System           │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  CRM / Sales / Subscription Platform               │    │
│  └─────────────────────────────────────────────────────┘    │
└─────────────────────────┬───────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                  FR-039A Commercial Contract                │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  TenantCommercialAccount Model                     │    │
│  │  ┌─────────────────────────────────────────────┐   │    │
│  │  │  tenant_id, plan_id, solutions, features   │   │    │
│  │  │  usage_limits, sla_tier, commercial_status │   │    │
│  │  │  prepaid_minimum_reserve_amount (contract)  │   │    │
│  │  └─────────────────────────────────────────────┘   │    │
│  │  Feature → Entitlement Mapping                     │    │
│  │  Commercial → License Translation                  │    │
│  └─────────────────────────────────────────────────────┘    │
└─────────────────────────┬───────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                  FR-038B License Lifecycle                  │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  Create/update license state                       │    │
│  │  Set expiry, entitlements, status (ACTIVE/SUSPEND)│    │
│  │  Revoke for BLOCKED/BLACKLISTED                   │    │
│  └─────────────────────────────────────────────────────┘    │
└─────────────────────────┬───────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                  FR-038A License Authorization              │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  Is capability authorized?                         │    │
│  │  Check license status and entitlements             │    │
│  └─────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
```

---

Appendix B — Plan Catalog Examples

```json
{
  "plans": [
    {
      "plan_id": "trial",
      "plan_name": "30-Day Trial",
      "billing_model": "subscription",
      "default_solutions": ["migration"],
      "default_features": ["internal_parallelism"],
      "default_usage_limits": {
        "max_data_gb_month": 100,
        "max_executions_month": 10,
        "max_concurrent_jobs": 2
      },
      "default_sla_tier": "standard",
      "default_prepaid_minimum_reserve_amount": 0
    },
    {
      "plan_id": "professional",
      "plan_name": "Professional",
      "billing_model": "subscription",
      "default_solutions": ["migration", "backup"],
      "default_features": ["internal_parallelism"],
      "default_usage_limits": {
        "max_data_gb_month": 2000,
        "max_executions_month": 200,
        "max_concurrent_jobs": 5
      },
      "default_sla_tier": "standard",
      "default_prepaid_minimum_reserve_amount": 0
    },
    {
      "plan_id": "enterprise",
      "plan_name": "Enterprise",
      "billing_model": "subscription",
      "default_solutions": ["migration", "backup", "reconciliation"],
      "default_features": ["dwe", "internal_parallelism", "advanced_reconciliation"],
      "default_usage_limits": {
        "max_data_gb_month": 10000,
        "max_executions_month": 500,
        "max_concurrent_jobs": 10
      },
      "default_sla_tier": "premium",
      "default_prepaid_minimum_reserve_amount": 5000
    },
    {
      "plan_id": "prepaid_enterprise",
      "plan_name": "Prepaid Enterprise",
      "billing_model": "hybrid",
      "default_solutions": ["migration", "backup", "reconciliation"],
      "default_features": ["dwe", "internal_parallelism", "advanced_reconciliation"],
      "default_usage_limits": {
        "max_data_gb_month": 10000,
        "max_executions_month": 500,
        "max_concurrent_jobs": 10
      },
      "default_sla_tier": "premium",
      "default_prepaid_minimum_reserve_amount": 10000
    }
  ]
}
```

---

Appendix C — Implementation Depth (v0.2.2)

Component Implementation
TenantCommercialAccount Model Define interface
Subscription Plan Model Define interface
Usage Limits Define schema
SLA Tier Define enum
Commercial Status Define enum (ACTIVE, SUSPENDED, BLOCKED, BLACKLISTED)
Prepaid Minimum Reserve Define policy field (contractual)
Feature → Entitlement Mapping Define mapping
Contract → License Translation Basic translation stub
External Subscription API Stub only
Payment Gateway Integration Not implemented (see FR-039B)
Invoice Generation Not implemented
Taxation Not implemented
Pricing Engine Not implemented (see FR-039B)

---

Appendix D — Future Extensibility

FR-039A is designed for future extension without modification:

Future Commercial Models:

· Usage-based pricing
· Hybrid subscription + usage
· Perpetual license
· Pay-as-you-go
· Reserved capacity

Future Contract Types:

· Enterprise agreement
· Partner/reseller contract
· Government contract
· Non-profit contract

Future SLA Tiers:

· Gold / Platinum / Diamond
· Custom SLA
· Regional SLA

Future Integrations:

· CRM integration (Salesforce)
· Subscription management (Zuora)
· Customer portal
· Self-service upgrades

Future Commercial Statuses:

· PENDING_ACTIVATION
· GRACE_PERIOD
· COMPLIANCE_REVIEW
