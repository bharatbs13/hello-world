# FR-039B — Usage, Billing, and Payment Integration Contracts

## Status
Approved

## Target Product Version
v0.2.2 (or later)

## Objective
Provide usage, billing, and payment integration contracts that enable Relix to capture consumption data, estimate billing, check prepaid reserve balances, and interface with external payment systems.

The framework shall define contracts for usage DB, billing DB, pricing table, payment gateway integration, and prepaid reserve checks. It shall also support pre-freeze reserve checks to gate execution for prepaid tenants, with configurable enforcement policies.

The objective is billing-readiness, not billing implementation.

---

## Scope

### Owns
- usage event schema
- usage DB interface contract
- billing DB interface contract
- pricing table interface contract (stub)
- estimated billing calculation contract
- prepaid reserve balance (current balance)
- prepaid reserve check interface (pre- and post-execution)
- reserve policy configuration (percentage, caps, billing mode, enforcement)
- payment gateway integration interface stub
- billing policy event contract
- overage event stub
- low-balance event stub
- payment-failed event stub
- usage audit metadata

### Does Not Own
- license authorization (see FR-038A)
- license lifecycle state changes (see FR-038B)
- commercial contract model (see FR-039A)
- actual payment gateway implementation (e.g., Stripe)
- invoice generation
- taxation
- collections
- revenue recognition
- resource allocation (see FR-040)

---

## Relationship to FR-039A, FR-038A, and FR-038B

FR-039A defines what is purchased and commercial status (including `prepaid_minimum_reserve_amount` policy).

FR-039B tracks current reserve balance, estimates billing, checks reserves, and emits events.

FR-038B uses payment/usage events to trigger license lifecycle changes.

FR-038A authorizes runtime requests.

```

Execution Request (pre-freeze)
↓
Pre-freeze: Reserve Check (FR-039B)
↓
If insufficient → emit event, block freeze
↓
Policy determines if FR-038B suspension triggered
↓
Plan Freeze / Execution
↓
Execution Completion
↓
Usage Captured (FR-039B)
↓
Usage DB Interface (FR-039B)
↓
Post-execution: Reserve Deduction / Billing Event
↓
Payment Gateway Interface (FR-039B)
↓
FR-038B (license lifecycle update if needed)

```

FR-039B shall not directly modify license state; it shall trigger FR-038B via events and policy.

---

## Principles

### Usage as the Source of Billing
Usage events shall be the primary input for billing and metering.

All execution consumption shall be captured as usage events.

### Pre-freeze Gating with Configurable Enforcement
For prepaid or hybrid billing models, a reserve check shall be performed before plan freeze.

If the reserve is insufficient, the plan freeze shall be blocked and a billing policy event emitted.

Whether this triggers license suspension is governed by commercial policy, not automatic.

### Eventual Consistency
Billing and payment integration shall be asynchronous and non-blocking to execution.

Usage capture shall not block the execution completion path.

### Provider-Neutral Payment Integration
Payment gateway integration shall be defined as a contract stub.

Actual payment providers (Stripe, Adyen, etc.) are pluggable without changing core logic.

### Separation of Estimation from Calculation
FR-039B produces estimated billing for informational purposes.

Actual invoicing and taxation are out of scope for v0.2.2.

### Configurable Reserve Policy
The reserve requirement shall be calculated using a configurable percentage of the estimated bill, with lower and upper caps.

This supports prepaid, postpaid, and hybrid billing modes without engine changes.

---

## Reserve Policy Configuration

FR-039B shall support a configurable reserve policy that determines the required reserve amount for an execution.

### Policy Parameters
```

ReservePolicy:
billing_mode: prepaid | postpaid | hybrid
enforcement_mode: block | warn_only | allow
reserve_percentage_of_estimate: decimal (0.0 to 1.0)
minimum_reserve_amount: decimal
maximum_reserve_amount: decimal

```

### Reserve Calculation
```

required_reserve =
clamp(
estimated_bill * reserve_percentage_of_estimate,
minimum_reserve_amount,
maximum_reserve_amount
)

```

### Supported Modes
| Mode | Description |
|------|-------------|
| prepaid | Required reserve deducted before execution; enforce `block` by default |
| postpaid | No reserve required; enforcement is `allow` or `warn_only` |
| hybrid | Reserve required for part of estimate; can be configured with lower percentage |

### Enterprise On-Prem Deployment
For on-prem or enterprise deployments, the same contract can be used with:
```

billing_mode: postpaid
enforcement_mode: allow
reserve_percentage_of_estimate: 0

```
This effectively disables reserve gating, allowing reporting-only billing behavior.

---

## Usage Event Model

### Usage Event Schema
```

UsageEvent:
event_id: string
tenant_id: string
execution_id: string
capability_id: string
solution: string
data_processed_gb: integer
duration_seconds: integer
parallelism_level: optional integer
dwe_nodes_used: optional integer
timestamp: timestamp
resource_metadata: object

```

### Example
```json
{
  "event_id": "usage-12345",
  "tenant_id": "bank_001",
  "execution_id": "exec-abc123",
  "capability_id": "dwe",
  "solution": "migration",
  "data_processed_gb": 250,
  "duration_seconds": 1800,
  "parallelism_level": 16,
  "dwe_nodes_used": 8,
  "timestamp": "2027-01-01T12:00:00Z",
  "resource_metadata": {
    "provider": "gcp",
    "region": "us-central1",
    "reservation_id": "res_abc123"
  }
}
```

---

Usage DB Interface Contract

Operations

```
UsageDB:
  store_usage_event(event: UsageEvent): void
  get_usage_for_period(tenant_id, from, to): list[UsageEvent]
  aggregate_usage(tenant_id, period, group_by): AggregatedUsage
  check_limit_exceeded(tenant_id, limit_type): boolean
```

Aggregated Usage

```
AggregatedUsage:
  tenant_id: string
  period_start: timestamp
  period_end: timestamp
  total_data_gb: integer
  total_executions: integer
  max_concurrent_jobs: integer
  total_duration_seconds: integer
  usage_by_capability: map[string, UsageSummary]
```

---

Billing DB Interface Contract

Operations

```
BillingDB:
  store_estimated_bill(tenant_id, period, amount, breakdown): void
  get_billing_history(tenant_id): list[Bill]
  get_prepaid_balance(tenant_id): decimal      # current balance
  update_prepaid_balance(tenant_id, amount): void
  record_payment(tenant_id, payment_id, amount, timestamp): void
```

Bill Model

```
Bill:
  bill_id: string
  tenant_id: string
  period_start: timestamp
  period_end: timestamp
  base_amount: decimal
  usage_amount: decimal
  overage_amount: decimal
  total_amount: decimal
  currency: string
  status: estimated | pending | paid | failed
  items: list[BillItem]
```

---

Pricing Table Interface Contract (Stub)

Operations

```
PricingTable:
  get_price(tenant_id, capability_id, usage_quantity): Price
  get_plan_base_price(tenant_id, plan_id): decimal
  get_overage_price(tenant_id, overage_type): decimal
```

Price Model

```
Price:
  unit: string (e.g., "per_gb", "per_hour", "per_execution")
  amount: decimal
  currency: string
```

---

Estimated Billing Contract

Input

```
EstimateBillingRequest:
  tenant_id: string
  usage_period: { from, to }
  usage_aggregate: AggregatedUsage
  plan: SubscriptionPlan      # from FR-039A
  pricing_table: PricingTable
  reserve_policy: ReservePolicy
```

Output

```
EstimatedBill:
  estimated_total: decimal
  required_reserve: decimal      # based on policy
  current_balance: decimal       # from billing DB
  reserve_status: SUFFICIENT | LOW_BALANCE | INSUFFICIENT
  breakdown: {
      base_fee: decimal,
      usage_fee: decimal,
      overage_fee: decimal,
      discount: optional decimal
  }
  currency: string
  due_date: timestamp
```

---

Prepaid Reserve Check Interface

FR-039B shall provide both pre-freeze and post-execution reserve check operations.

Operations

```
PrepaidReserve:
  get_current_balance(tenant_id): decimal
  check_reserve(tenant_id, estimated_amount, reserve_policy): ReserveStatus
  deduct_reserve(tenant_id, actual_amount): DeductResult
  add_reserve(tenant_id, amount): void
```

ReserveStatus

```
ReserveStatus:
  status: SUFFICIENT | LOW_BALANCE | INSUFFICIENT
  current_balance: decimal
  required_reserve: decimal       # estimated amount for upcoming execution
  warning_threshold: decimal
  recommendation: optional string
```

DeductResult

```
DeductResult:
  success: boolean
  new_balance: decimal
  deduction_amount: decimal
  error_code: optional string
```

---

Payment Gateway Integration Interface Stub

Operations

```
PaymentGateway:
  authorize_payment(tenant_id, amount, method): AuthResult
  capture_payment(authorization_id): CaptureResult
  refund_payment(transaction_id, amount): RefundResult
  get_payment_methods(tenant_id): list[PaymentMethod]
```

AuthResult

```
AuthResult:
  success: boolean
  authorization_id: string
  error_code: optional string
  error_message: optional string
```

---

Billing Policy Events

FR-039B shall emit events for billing policy decisions.

Events:

· BILLING_USAGE_RECORDED
· BILLING_USAGE_AGGREGATED
· BILLING_ESTIMATE_GENERATED
· BILLING_OVERAGE_DETECTED
· BILLING_LOW_BALANCE_DETECTED
· BILLING_PREPAID_INSUFFICIENT
· BILLING_PREPAID_DEDUCTED
· BILLING_RESERVE_CHECK_PASSED (pre-freeze)
· BILLING_RESERVE_CHECK_FAILED (pre-freeze; blocks freeze, may trigger suspension via policy)
· BILLING_PAYMENT_FAILED
· BILLING_PAYMENT_SUCCEEDED

---

Audit Metadata

Billing and usage events shall be auditable.

Audit metadata may include:

· tenant_id
· execution_id
· event_type
· usage_aggregate (hash)
· estimated_amount
· required_reserve
· current_balance
· reserve_policy_applied
· payment_result
· reserve_status
· timestamp

---

Failure Handling

Billing failures shall not block execution completion, but reserve checks shall block plan freeze when insufficient, with policy-driven actions.

If usage DB write fails:

· Error shall be logged
· Retry shall be attempted
· Manual reconciliation required if persistent

If pre-freeze reserve check returns INSUFFICIENT:

· Event BILLING_RESERVE_CHECK_FAILED emitted
· Plan freeze blocked
· FR-038B license suspension may be triggered according to configured commercial policy

If post-execution reserve deduction fails:

· Error logged
· Event emitted
· Manual reconciliation required

If payment authorization fails:

· Event BILLING_PAYMENT_FAILED emitted
· License may be suspended via FR-038B based on policy
· Execution already completed

---

Acceptance Criteria

AC# Description
AC1 Relix shall define a usage event schema.
AC2 Relix shall define a usage DB interface contract.
AC3 Relix shall define a billing DB interface contract.
AC4 Relix shall define a pricing table interface contract.
AC5 Relix shall define an estimated billing contract.
AC6 Relix shall define a prepaid reserve check interface.
AC7 Relix shall support pre-freeze reserve checks to gate execution.
AC8 Insufficient reserve pre-freeze shall emit BILLING_RESERVE_CHECK_FAILED and block plan freeze.
AC9 FR-038B license suspension may be triggered according to configured commercial policy.
AC10 Relix shall define a payment gateway integration stub.
AC11 Relix shall emit billing policy events.
AC12 Relix shall maintain audit trail of usage and billing events.
AC13 FR-039B shall not implement actual payment processing.
AC14 FR-039B shall not block execution on post-execution billing failures.
AC15 Billing events shall trigger FR-038B license lifecycle updates when needed.
AC16 Current prepaid balance is owned by FR-039B.
AC17 Relix shall support configurable reserve policy using percentage of estimated bill with lower and upper caps.
AC18 Relix shall support prepaid, postpaid, and hybrid reserve modes through configuration.

---

Design Rule

Usage, billing, and payment integration are separate from runtime execution.

FR-039B captures usage after execution completes.

FR-039B emits events that may trigger license lifecycle changes via FR-038B.

FR-039B does not directly enforce authorization; that is FR-038A.

FR-039B is contract-only for v0.2.2: interfaces, models, events, and stubs.

Pre-freeze reserve checks are a gate for prepaid tenants; insufficient reserve blocks plan freeze and emits an event; whether this triggers suspension is governed by commercial policy.

Reserve policies are configurable per tenant, allowing the same engine to support prepaid, postpaid, hybrid, and on-prem enterprise deployments.

---

Appendix A — Integration Architecture

Two-Path Flow

```
Execution Request
        |
        v
Pre-freeze Reserve Check (FR-039B)
        |
        v
Calculate Required Reserve (policy-based)
        |
        v
Check current balance
        |
        +-- SUFFICIENT → allow freeze
        |
        +-- LOW_BALANCE → emit event, allow/warn based on policy
        |
        +-- INSUFFICIENT → emit event, block freeze
        |
        v
Plan Freeze / Execution
        |
        v
Post-execution Usage Capture (FR-039B)
        |
        v
Usage DB (contract)
        |
        v
Reserve Deduction / Billing Event
        |
        v
Payment Gateway Stub (contract)
```

---

Appendix B — Implementation Depth (v0.2.2)

Component Implementation
Usage Event Schema Define interface
Usage DB Interface Define interface, in-memory stub
Billing DB Interface Define interface, in-memory stub
Pricing Table Interface Define interface, static stub
Estimated Billing Basic calculation stub
Reserve Policy Config Define schema, in-memory stub
Prepaid Reserve Check Basic balance check stub with policy
Pre-freeze Gating Policy enforcement stub
Payment Gateway Interface Stub only
Actual Payment Gateway Not implemented
Invoice Generation Not implemented
Taxation Not implemented
Collections Not implemented

---

Appendix C — Policy Configuration Examples

SaaS Prepaid

```yaml
billing_mode: prepaid
enforcement_mode: block
reserve_percentage_of_estimate: 0.20
minimum_reserve_amount: 100.00
maximum_reserve_amount: 10000.00
```

SaaS Hybrid

```yaml
billing_mode: hybrid
enforcement_mode: warn_only
reserve_percentage_of_estimate: 0.10
minimum_reserve_amount: 50.00
maximum_reserve_amount: 5000.00
```

SaaS Postpaid

```yaml
billing_mode: postpaid
enforcement_mode: allow
reserve_percentage_of_estimate: 0.00
minimum_reserve_amount: 0.00
maximum_reserve_amount: 0.00
```

Enterprise On-Prem (Reporting-Only)

```yaml
billing_mode: postpaid
enforcement_mode: allow
reserve_percentage_of_estimate: 0.00
minimum_reserve_amount: 0.00
maximum_reserve_amount: 0.00
```

---

Appendix D — Future Extensibility

FR-039B is designed for future extension without modification:

Future Payment Providers:

· Stripe integration
· Adyen integration
· Braintree integration
· PayPal integration
· Bank transfer

Future Billing Models:

· Postpaid invoicing
· Prepaid top-up
· Reserved capacity credits
· Coupon/discount application

Future Integrations:

· ERP integration (SAP, Oracle)
· Revenue recognition
· Tax compliance (Avalara)
· Usage-based billing (Metering)

Future Metering:

· Real-time usage tracking
· Usage forecasting
· Anomaly detection

Future Reserve Policies:

· Dynamic reserve based on historical usage
· Minimum reserve thresholds
· Auto-top-up rules
