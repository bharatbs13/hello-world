# FR-039 — Commercial Integration Hooks

## Status
Draft

## Target Product Version
v0.2.2

## Objective
Provide commercial integration hooks that allow future billing, subscription, enterprise contract, and SaaS control-plane systems to supply license and entitlement state to Relix without coupling commercial logic to the deterministic execution core.

FR-039 extends the FR-038 License Governance Framework by defining provider interfaces, refresh hooks, entitlement update events, and usage event contracts.

The objective is commercial-readiness, not billing implementation.

---

## Scope

### Owns
- external entitlement provider interface
- license source abstraction
- entitlement refresh hook
- entitlement update event
- capability usage event
- provider-neutral license loading
- provider-neutral entitlement loading
- integration contract for future billing or subscription systems

### Does Not Own
- billing
- invoicing
- payment processing
- subscription management
- pricing plans
- payment gateway integration
- SaaS control plane
- customer portal
- tax handling
- invoice reconciliation
- revenue recognition
- capability implementation
- workflow orchestration
- execution planning

---

## Relationship to FR-038A and FR-038B

FR-038A owns runtime license authorization.

FR-038B owns license lifecycle state updates.

FR-039 supplies commercial integration hooks and provider-fed state.

```
External Commercial System
        ↓
Commercial Integration Hook (FR-039)
        ↓
FR-038B — License Lifecycle Management
        ↓
FR-038A — License Authorization Framework
        ↓
Capability Authorization
```

**FR-038A decides:** ALLOW | DENY

**FR-038B applies:** refreshed license / entitlement state

**FR-039 provides:**
- provider-neutral license loading
- entitlement refresh hooks
- entitlement update events
- capability usage events

FR-039 shall not override FR-038A authorization logic or FR-038B lifecycle rules.

---

## Principles

### Commercial Logic Isolation
Commercial systems shall not be embedded in the Relix execution core.

The execution core shall not know about:
- prices
- invoices
- payments
- contracts
- subscription plans
- payment gateways

The execution core shall consume only license and entitlement state.

---

### Provider-Neutral Integration
Relix shall support provider-neutral license and entitlement loading.

Supported provider types may include:
- file provider
- environment provider
- remote provider stub
- future SaaS provider
- future enterprise license server provider

Only provider contracts are required in this FR. External commercial systems may be implemented later.

---

### Billing-Ready, Not Billing-Owned
FR-039 shall make Relix billing-ready by emitting usage and entitlement events.

FR-039 shall not calculate bills, generate invoices, or process payments.

---

## Provider Model

FR-039 shall define an entitlement provider interface.

A provider may supply:
- product license
- entitlement set
- provider metadata
- refresh timestamp
- source identifier

**Example provider responsibilities:**
```
load_license()
load_entitlements()
refresh()
get_provider_metadata()
```

---

## Provider Types

### File Provider
Loads license and entitlement state from local configured files.

**Used for:**
- local development
- offline enterprise deployment
- private customer deployment

### Environment Provider
Loads license and entitlement references from environment configuration.

**Used for:**
- CI/CD pipelines
- controlled deployment environments
- simple runtime overrides

### Remote Provider Stub
Defines a future remote entitlement source contract.

**Used for:**
- SaaS control plane integration
- subscription system integration
- enterprise license server integration

The remote provider may be a stub in v0.2.2 and shall not require live network connectivity.

---

## Entitlement Refresh

Relix shall support explicit entitlement refresh.

**Refresh may be triggered by:**
- operator action
- deployment startup
- scheduled future process
- external provider update

**Refresh behavior:**
- Shall provide refreshed license and entitlement state to FR-038B
- FR-038B shall apply lifecycle state updates
- FR-038A shall consume the resulting current license state
- Shall emit observable events
- Shall maintain atomic state updates
- Shall not corrupt existing license state on failure

---

## Usage Events

Relix shall emit capability usage events that future billing or reporting systems may consume.

**Usage events may include:**
- `customer_id`
- `license_id`
- `capability_id`
- `execution_id`
- `timestamp`
- `authorization_decision`
- `usage_metadata`

FR-039 shall not calculate charges from usage events.

---

## Events

FR-039 shall support commercial integration events.

**Events:**
- `ENTITLEMENT_PROVIDER_LOADED`
- `ENTITLEMENT_REFRESH_STARTED`
- `ENTITLEMENT_REFRESH_COMPLETED`
- `ENTITLEMENT_REFRESH_FAILED`
- `ENTITLEMENT_UPDATED`
- `CAPABILITY_USAGE_RECORDED`

---

## Audit Metadata

Commercial integration decisions shall be auditable.

**Audit metadata may include:**
- `provider_type`
- `provider_id`
- `license_id`
- `customer_id`
- `capability_id`
- `refresh_timestamp`
- `event_id`
- `source_uri` or `source_reference`

---

## Failure Handling

Provider failures shall fail safely.

**If entitlement state cannot be loaded:**
- Authorization shall not silently allow licensed capabilities
- Actionable error shall be emitted
- Failure shall be observable
- Previous valid frozen execution plans shall remain protected according to FR-038A policy

Provider failure shall not corrupt stored license state.

---

## Offline Compatibility

FR-039 shall support offline-compatible deployments.

**File-based provider behavior shall be sufficient for:**
- disconnected enterprise environments
- private cloud deployments
- manual license renewal
- non-SaaS customer installations

Remote provider support may be introduced later without changing FR-038A or FR-038B.

---

## Acceptance Criteria

| AC# | Description |
|-----|-------------|
| AC1 | Relix shall define a provider-neutral entitlement provider interface. |
| AC2 | Relix shall support a file-based license and entitlement provider. |
| AC3 | Relix shall support an explicit entitlement refresh hook. |
| AC4 | Relix shall emit entitlement refresh events. |
| AC5 | Relix shall emit entitlement update events when provider state changes. |
| AC6 | Relix shall emit capability usage events for future billing or reporting systems. |
| AC7 | Relix shall not implement billing, invoicing, payment processing, pricing plans, or subscription management in this FR. |
| AC8 | Relix shall support offline-compatible entitlement loading. |
| AC9 | Provider failures shall fail safely and shall not silently allow licensed capabilities. |
| AC10 | FR-039 shall not override or duplicate FR-038A authorization logic or FR-038B lifecycle logic. |

---

## Design Rule

Commercial integration is an adapter layer around license governance.

FR-039 supplies license and entitlement state.

FR-038B applies refreshed state to license lifecycle management.

FR-038A evaluates license and entitlement state for runtime authorization.

The Relix execution core shall remain independent of billing, subscription, pricing, and payment systems.

---

## Appendix A — Integration Architecture

### Component Diagram
```
┌─────────────────────────────────────────────────────────────┐
│                     External Commercial Systems              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────┐  │
│  │   Billing    │  │ Subscription │  │  SaaS Control    │  │
│  │   System     │  │   System     │  │      Plane       │  │
│  └──────────────┘  └──────────────┘  └──────────────────┘  │
└─────────────────────────┬───────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                  FR-039 Commercial Hooks                     │
│  ┌─────────────────────────────────────────────────────┐    │
│  │           Provider Interface Layer                   │    │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────────────┐  │    │
│  │  │   File   │  │ Environ  │  │  Remote Stub     │  │    │
│  │  │ Provider │  │ Provider │  │    (Future)      │  │    │
│  │  └──────────┘  └──────────┘  └──────────────────┘  │    │
│  └─────────────────────────────────────────────────────┘    │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────┐  │
│  │   Refresh    │  │   Update     │  │     Usage        │  │
│  │    Hooks     │  │   Events     │  │    Events        │  │
│  └──────────────┘  └──────────────┘  └──────────────────┘  │
└─────────────────────────┬───────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                  FR-038 License Governance                   │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  FR-038B — License Lifecycle Management              │    │
│  │  (Applies refreshed state)                           │    │
│  └─────────────────────────────────────────────────────┘    │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  FR-038A — License Authorization                     │    │
│  │  (Evaluates state, decides ALLOW/DENY)              │    │
│  └─────────────────────────────────────────────────────┘    │
└─────────────────────────┬───────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                     Relix Execution Core                    │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────┐  │
│  │  Capability  │  │  Workflow    │  │   Execution      │  │
│  │   Registry   │  │  Engine      │  │    Planner       │  │
│  └──────────────┘  └──────────────┘  └──────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

### Data Flow

```
1. Provider loads license/entitlement state via FR-039
2. FR-039 emits ENTITLEMENT_PROVIDER_LOADED event
3. FR-038B applies lifecycle state update
4. FR-038A authorizes capabilities using current state
5. FR-039 emits CAPABILITY_USAGE_RECORDED for authorized executions
6. Future billing systems consume usage events via FR-039
```

---

## Appendix B — Provider Contract Examples

### File Provider Contract
```yaml
# license.yaml
license_id: "LIC-2027-001"
customer_id: "CUST-12345"
license_type: "enterprise"
status: "ACTIVE"
issue_date: "2027-01-01"
expiry: "2027-12-31"
grace_period: 30
entitlements:
  - capability_id: "parallelism"
    expiry: "2027-12-31"
  - capability_id: "agent_assistant"
    expiry: "2027-06-30"
```

### Environment Provider Contract
```bash
RELIX_LICENSE_ID=LIC-2027-001
RELIX_LICENSE_FILE=/etc/relix/license.yaml
RELIX_PROVIDER_TYPE=file
RELIX_REFRESH_INTERVAL=3600
```

### Remote Provider Stub Contract
```json
{
  "provider_type": "remote",
  "endpoint": "https://license-service.example.com/v1/entitlements",
  "auth_method": "api_key",
  "refresh_interval": 300,
  "timeout": 5000,
  "retry_count": 3
}
```

---

## Appendix C — Event Schema Examples

### Entitlement Refresh Event
```json
{
  "event_type": "ENTITLEMENT_REFRESH_COMPLETED",
  "provider_type": "file",
  "license_id": "LIC-2027-001",
  "entitlement_count": 5,
  "refresh_timestamp": "2027-01-01T00:00:00Z",
  "status": "success"
}
```

### Capability Usage Event
```json
{
  "event_type": "CAPABILITY_USAGE_RECORDED",
  "customer_id": "CUST-12345",
  "license_id": "LIC-2027-001",
  "capability_id": "parallelism",
  "execution_id": "exec-abc123",
  "timestamp": "2027-01-01T00:00:00Z",
  "authorization_decision": "ALLOW",
  "usage_metadata": {
    "parallelism_level": 8,
    "duration_seconds": 120
  }
}
```

---

## Appendix D — Supported Deployment Models

| Model | Provider Type | Refresh Method | Connectivity |
|-------|--------------|----------------|--------------|
| SaaS | Remote | Scheduled/Poll | Required |
| Enterprise On-Prem | File | Manual/Startup | Optional |
| Hybrid | Remote + File | Scheduled + Fallback | Optional |
| Development | Environment | Startup | None |
| CI/CD | Environment | Startup | None |
| Air-Gapped | File | Manual | None |
