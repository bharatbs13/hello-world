
# FR-040 — Resource Allocation Contract

## Status
Approved

## Target Product Version
v0.2.2 (or later)

## Objective
Provide a resource allocation contract that enables Relix to estimate, recommend, or reserve compute resources for execution plans based on solution requirements, data size, SLA targets, and deployment mode.

The framework shall support both advisory estimation for customer-cloud data planes and authoritative logical reservation (intent-based) for vendor-cloud data planes.

The objective is resource planning readiness, not dynamic autoscaling or physical provisioning implementation.

---

## Scope

### Owns
- resource request contract
- resource plan contract
- resource reservation interface
- allocation decision metadata
- execution mode selection
- deployment mode awareness
- resource eligibility gate
- allocation recommendation logic
- resource provider abstraction
- default resource provider selection
- provider-neutral resource model
- provider selection policy

### Does Not Own
- actual autoscaling
- Kubernetes provisioning
- direct cloud-specific provisioning APIs
- provider-specific infrastructure lifecycle
- physical infrastructure provisioning
- billing calculation
- execution scheduling
- VPN setup
- VPC peering
- PrivateLink configuration
- inter-cloud routing
- customer cloud IAM setup
- actual resource provisioning
- connectivity validation (see FR-041)

---

## Relationship to FR-038A

FR-038A owns license authorization (Gate 1).

FR-040 owns resource allocation and estimation (Gate 2).

```

Request
↓
Gate 1: FR-038A — License Authorization
↓
AuthorizationResult (authorized capabilities)
↓
Gate 2: FR-040 — Resource Allocation Contract
↓
Gate 3: FR-041 — Connectivity Validation (conditional)
↓
Plan Freeze
↓
Execution

```

FR-040 shall only evaluate resource requirements for authorized capabilities.

FR-040 shall not determine commercial entitlement.

FR-040 shall receive authorized capabilities from FR-038A, not license internals.

---

## Principles

### License First
License authorization shall precede resource allocation.

FR-040 shall only evaluate resource requirements for authorized capabilities.

If FR-038A denies a capability, FR-040 shall not estimate or allocate resources for it.

### Deployment Mode Awareness
FR-040 shall support two deployment modes:

1. **Customer-Cloud Data Plane**
   - Estimate and recommend only
   - Resources are advisory
   - No physical provisioning by Relix
   - Provider fields are metadata only (customer owns infrastructure)

2. **Vendor-Cloud Data Plane**
   - Estimate and reserve logical (intent-based) allocation
   - Resource plan is authoritative
   - Physical provisioning is delegated to future infrastructure providers
   - Provider selection is policy-controlled

### Capability-Aware Estimation
FR-040 shall consider authorized execution modes when estimating resources.

FR-040 shall not know why a capability is missing, only which modes are allowed.

### Separation from Provisioning
FR-040 shall define resource requirements and create logical reservations.

FR-040 shall not implement:
- Kubernetes pod creation
- VM provisioning
- Container orchestration
- Cloud API calls

### Provider-Neutral Abstraction
FR-040 shall use a provider-neutral resource abstraction.

Adding a new resource provider shall not require changes to the resource allocation contract.

### Policy-Controlled Provider Selection (Vendor-Cloud)
Resource provider selection shall be controlled by platform policy, not ordinary user input.

Users may express preferences or constraints, but the platform selects the actual provider based on:
- cost
- capacity
- region availability
- compliance requirements
- support/SLA
- operational responsibility
- customer contract terms

### Fail-Safe Provider Handling
If a requested provider is unsupported, FR-040 shall fail safely and block plan freeze.

Fallback to default provider is allowed only when explicitly permitted by resource policy.

---

## Resource Provider Model

FR-040 shall define a provider-neutral resource abstraction.

### Provider Interface
```

ResourceProvider:
provider_id: string
region: string
resource_family: string
capacity_policy: object
cost_policy: object
metadata: object

```

### Supported Providers (v0.2.2)

| Provider | Status |
|----------|--------|
| GCP | Default / Implemented |
| AWS | Future (not implemented) |
| Azure | Future (not implemented) |
| On-Prem | Future (not implemented) |

### Provider Selection Policy (Vendor-Cloud Only)

**System Default:**
```

system_default_provider: gcp

```

**Provider Selection Logic:**
1. Start with system default provider
2. Apply platform policy overrides
3. Apply customer constraints (if applicable)
4. Validate provider is supported
5. Apply region availability
6. Select final provider
7. Record selection reason

**Unsupported Provider Handling:**
- If requested provider is unsupported → REJECT with error
- No automatic fallback to default provider
- Error message shall identify unsupported provider
- Plan freeze blocked

**Provider Preference vs Constraint:**
- `provider_preference`: User expression of desired provider (advisory)
- `provider_constraint`: Contractual or compliance requirement (mandatory if supported)

### Customer-Cloud Metadata
For customer-cloud mode, provider fields are informational only. Relix does not select a provider.

- `customer_environment.provider`: string (e.g., aws, gcp, azure, on_prem)
- `customer_environment.region`: optional string

These are used for recommendation context only (e.g., region-specific suggestions) and do not influence allocation.

---

## Resource Request Contract

### Input
```

ResourceRequest:
solution: string
estimated_data_size_gb: integer
desired_sla_minutes: integer
deployment_mode: customer_cloud_data_plane | vendor_cloud_data_plane
tenant_id: optional string
priority: normal | high
region_preference: optional string

Vendor-cloud only:

provider_preference: optional string
provider_constraint: optional string

Customer-cloud only (metadata):

customer_environment: optional object
provider: string
region: optional string

authorized_capabilities:
- serial
- internal_parallelism
- dwe

```

### Example — Vendor-Cloud (GCP Default)
```json
{
  "solution": "migration",
  "estimated_data_size_gb": 500,
  "desired_sla_minutes": 60,
  "deployment_mode": "vendor_cloud_data_plane",
  "tenant_id": "tenant-123",
  "priority": "high",
  "region_preference": "us-central1",
  "authorized_capabilities": ["serial", "internal_parallelism"]
}
```

Example — Vendor-Cloud (Provider Constraint Supported)

```json
{
  "solution": "migration",
  "estimated_data_size_gb": 500,
  "desired_sla_minutes": 60,
  "deployment_mode": "vendor_cloud_data_plane",
  "tenant_id": "tenant-456",
  "priority": "high",
  "region_preference": "europe-west1",
  "provider_constraint": "gcp_only",
  "authorized_capabilities": ["serial", "internal_parallelism", "dwe"]
}
```

Example — Vendor-Cloud (Provider Constraint Unsupported)

```json
{
  "solution": "migration",
  "estimated_data_size_gb": 500,
  "desired_sla_minutes": 60,
  "deployment_mode": "vendor_cloud_data_plane",
  "tenant_id": "tenant-789",
  "priority": "high",
  "provider_constraint": "aws_only",
  "authorized_capabilities": ["serial", "internal_parallelism", "dwe"]
}
```

Example — Customer-Cloud Mode

```json
{
  "solution": "migration",
  "estimated_data_size_gb": 50,
  "desired_sla_minutes": 120,
  "deployment_mode": "customer_cloud_data_plane",
  "tenant_id": "tenant-999",
  "priority": "normal",
  "customer_environment": {
    "provider": "aws",
    "region": "us-east-1"
  },
  "authorized_capabilities": ["serial", "internal_parallelism"]
}
```

---

Resource Plan Contract

Output — Customer-Cloud Data Plane

```
ResourcePlan:
  mode: recommendation_only
  recommended_execution_mode: serial | internal_parallelism | dwe
  recommended_workers: integer
  recommended_memory_gb: integer
  estimated_duration_minutes: integer
  estimated_cost_units: integer
  allocation_reason: string
  note: customer_cloud_resources_not_allocated_by_relix
```

Example — Customer-Cloud

```json
{
  "mode": "recommendation_only",
  "recommended_execution_mode": "internal_parallelism",
  "recommended_workers": 8,
  "recommended_memory_gb": 32,
  "estimated_duration_minutes": 55,
  "estimated_cost_units": 120,
  "allocation_reason": "sla_target_requires_parallelism",
  "note": "customer_cloud_resources_not_allocated_by_relix"
}
```

Output — Vendor-Cloud Data Plane

```
ResourcePlan:
  mode: resource_intent_reservation
  selected_execution_mode: serial | internal_parallelism | dwe
  reserved_workers: integer
  reserved_memory_gb: integer
  estimated_duration_minutes: integer
  estimated_cost_units: integer
  reservation_id: string
  allocation_reason: string
  resource_metadata: object
```

Example — Vendor-Cloud (GCP Default — Success)

```json
{
  "mode": "resource_intent_reservation",
  "selected_execution_mode": "dwe",
  "reserved_workers": 16,
  "reserved_memory_gb": 64,
  "estimated_duration_minutes": 45,
  "estimated_cost_units": 240,
  "reservation_id": "res_abc123",
  "allocation_reason": "large_data_volume_requires_dwe",
  "resource_metadata": {
    "provider": "gcp",
    "provider_selection_reason": "system_default_provider",
    "compute_class": "standard-memory-optimized",
    "region": "us-central1",
    "reserved_at": "2027-01-01T00:00:00Z"
  }
}
```

---

Error Response — Unsupported Provider

```json
{
  "error": "RESOURCE_PROVIDER_UNSUPPORTED",
  "message": "Provider constraint 'aws_only' cannot be satisfied. Supported providers: [gcp]",
  "plan_freeze_blocked": true
}
```

---

Execution Mode Selection

The allocation engine may decide execution mode based on:

Input Factors:

· solution type
· estimated data size
· desired SLA
· authorized capabilities
· deployment mode
· resource policy

Decision Logic Example:

```
if estimated_data_size_gb < 100 and desired_sla_minutes > 120:
    → serial
else if estimated_data_size_gb < 1000 and internal_parallelism in authorized_capabilities:
    → internal_parallelism
else if estimated_data_size_gb >= 1000 and dwe in authorized_capabilities:
    → dwe
else if estimated_data_size_gb >= 1000 and dwe not in authorized_capabilities:
    → internal_parallelism (with warning)
else if dwe_not_authorized and internal_parallelism_not_authorized:
    → serial (with SLA warning)
```

FR-040 shall not know why dwe is missing. It only evaluates authorized_capabilities.

---

Resource Policy

FR-040 may support configurable resource policies.

Policy Parameters:

· max_workers
· max_memory_gb
· min_workers
· min_memory_gb
· default_execution_mode
· deployment_mode_overrides
· region_capacity
· provider_capacity
· default_provider
· provider_selection_policy
· allow_fallback_to_default (boolean, default: false)

---

Observability

FR-040 shall emit resource planning events.

Events:

· RESOURCE_PLANNING_STARTED
· RESOURCE_PLANNING_COMPLETED
· RESOURCE_RESERVATION_REQUESTED
· RESOURCE_RESERVATION_APPROVED
· RESOURCE_RESERVATION_DENIED
· RESOURCE_RECOMMENDATION_ISSUED
· EXECUTION_MODE_SELECTED
· RESOURCE_PROVIDER_SELECTED
· RESOURCE_PROVIDER_UNSUPPORTED

---

Audit Metadata

Resource allocation decisions shall be auditable.

Audit metadata may include:

· request_id
· solution
· estimated_data_size_gb
· desired_sla_minutes
· deployment_mode
· provider_preference (if provided)
· provider_constraint (if provided)
· selected_provider
· provider_selection_reason
· authorized_capabilities
· selected_execution_mode
· reserved_workers
· reserved_memory_gb
· estimated_duration_minutes
· allocation_reason
· decision_timestamp

---

Failure Handling

Resource allocation failures shall fail safely.

If resource plan cannot be generated:

· Actionable error shall be emitted
· Failure shall be observable
· Plan freeze shall not proceed
· License state shall remain unaffected

If provider constraint cannot be satisfied:

· Error shall be emitted: RESOURCE_PROVIDER_UNSUPPORTED
· Request shall be rejected with clear reason
· Plan freeze blocked
· Fallback to default provider shall not occur unless explicitly permitted by policy

Supported provider check:

```
if provider_constraint not in supported_providers:
    → REJECT
    → error: "Provider constraint '{provider}' cannot be satisfied. Supported providers: [gcp]"
    → block plan freeze
```

---

Acceptance Criteria

AC# Description
AC1 Relix shall define a resource request contract.
AC2 Relix shall define a resource plan contract.
AC3 Relix shall support advisory estimation for customer-cloud data planes.
AC4 Relix shall support resource intent reservation for vendor-cloud data planes.
AC5 Relix shall select execution mode based on resource input and authorized capabilities.
AC6 Relix shall consider authorized capabilities when selecting execution mode.
AC7 Relix shall emit resource planning events.
AC8 Relix shall maintain audit trail of resource allocation decisions.
AC9 License authorization (FR-038A) shall precede resource allocation.
AC10 Resource allocation failures shall block plan freeze.
AC11 FR-040 shall not implement physical resource provisioning (Kubernetes, cloud VMs, etc.).
AC12 FR-040 shall receive authorized capabilities from FR-038A, not license internals.
AC13 Relix shall define a provider-neutral resource abstraction.
AC14 Relix shall support GCP as the default resource provider.
AC15 Adding a new resource provider shall not require changes to the resource allocation contract.
AC16 Provider selection (vendor-cloud) shall be controlled by platform policy, not ordinary user input.
AC17 Users may express provider preference or constraint, but platform selects final provider.
AC18 Provider selection reason shall be recorded in audit metadata.
AC19 If requested provider is unsupported, FR-040 shall reject and block plan freeze.
AC20 Fallback to default provider shall not occur unless explicitly permitted by resource policy.
AC21 Unsupported provider shall emit RESOURCE_PROVIDER_UNSUPPORTED event.
AC22 Customer-cloud mode shall accept customer_environment metadata but shall not select provider.

---

Design Rule

Resource allocation is a planning gate, not an execution engine.

FR-040 estimates and recommends resources for customer-cloud data planes.

FR-040 reserves logical (intent-based) resources for vendor-cloud data planes.

FR-040 does not provision physical infrastructure.

FR-038A is the first gate. FR-040 is the second gate.

Resource allocation shall not determine commercial entitlement. License authorization shall not calculate resource requirements.

FR-040 consumes authorized capabilities from FR-038A, not license internals.

FR-040 uses a provider-neutral abstraction. GCP is the default provider. AWS, Azure, and on-premise providers are pluggable without changing the contract.

Provider selection is controlled by platform policy. Users may express preferences or constraints, but the platform selects the actual provider based on cost, capacity, compliance, and operational responsibility.

Unsupported providers are rejected safely. No automatic fallback.

---

Appendix A — Integration Architecture

Component Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                     User Request                            │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  solution, data_size, sla, deployment_mode         │    │
│  │  provider_preference (optional, vendor-cloud)      │    │
│  │  provider_constraint (optional, vendor-cloud)      │    │
│  │  customer_environment (optional, customer-cloud)   │    │
│  └─────────────────────────────────────────────────────┘    │
└─────────────────────────┬───────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                  Gate 1: FR-038A License                    │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  Is capability authorized?                         │    │
│  │  Return authorized_capabilities list               │    │
│  └─────────────────────────────────────────────────────┘    │
└─────────────────────────┬───────────────────────────────────┘
                          │ (PASS)
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                  Gate 2: FR-040 Resource                    │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  Provider Selection Policy (vendor-cloud only)     │    │
│  │  ┌─────────────────────────────────────────────┐   │    │
│  │  │  1. System default: gcp                    │   │    │
│  │  │  2. Apply platform policy overrides        │   │    │
│  │  │  3. Apply customer constraints (if any)    │   │    │
│  │  │  4. Validate provider is supported         │   │    │
│  │  │  5. If unsupported → REJECT               │   │    │
│  │  │  6. Apply region availability              │   │    │
│  │  │  7. Select final provider                  │   │    │
│  │  │  8. Record selection reason                │   │    │
│  │  └─────────────────────────────────────────────┘   │    │
│  │  ┌─────────────────────────────────────────────┐   │    │
│  │  │  Resource Provider Abstraction              │   │    │
│  │  │  ┌──────────┐  ┌──────────┐  ┌──────────┐ │   │    │
│  │  │  │   GCP    │  │   AWS    │  │  Azure   │ │   │    │
│  │  │  │ Default  │  │ (Future) │  │ (Future) │ │   │    │
│  │  │  └──────────┘  └──────────┘  └──────────┘ │   │    │
│  │  └─────────────────────────────────────────────┘   │    │
│  │  Estimate / reserve resources                      │    │
│  │  Select execution mode                             │    │
│  │  Return resource plan                              │    │
│  └─────────────────────────────────────────────────────┘    │
└─────────────────────────┬───────────────────────────────────┘
                          │
                          ▼ (conditional)
┌─────────────────────────────────────────────────────────────┐
│                  Gate 3: FR-041 Connectivity                │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  Customer-cloud: validate connectivity             │    │
│  │  Vendor-cloud: skip                                │    │
│  └─────────────────────────────────────────────────────┘    │
└─────────────────────────┬───────────────────────────────────┘
                          │ (PASS)
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                      Plan Freeze                            │
└─────────────────────────────────────────────────────────────┘
```

---

Appendix B — Decision Matrix Examples

Example 1: Small Migration, Customer-Cloud

```
Input:
  solution: migration
  estimated_data_size_gb: 50
  desired_sla_minutes: 120
  deployment_mode: customer_cloud_data_plane
  customer_environment: { provider: "aws", region: "us-east-1" }
  authorized_capabilities: [serial, internal_parallelism]

Policy:
  default_provider: gcp (ignored for customer-cloud)

Output:
  mode: recommendation_only
  recommended_execution_mode: serial
  recommended_workers: 1
  recommended_memory_gb: 16
  estimated_duration_minutes: 110
  allocation_reason: small_data_size_serial_adequate
  note: customer_cloud_resources_not_allocated_by_relix
```

Example 2: Large Migration, Vendor-Cloud (GCP Default — Success)

```
Input:
  solution: migration
  estimated_data_size_gb: 1500
  desired_sla_minutes: 45
  deployment_mode: vendor_cloud_data_plane
  authorized_capabilities: [serial, internal_parallelism, dwe]

Policy:
  default_provider: gcp
  supported_providers: [gcp]

Processing:
  provider_constraint: none
  provider_preference: none
  → selected_provider: gcp (system default)
  → supported: yes

Output:
  mode: resource_intent_reservation
  selected_execution_mode: dwe
  reserved_workers: 24
  reserved_memory_gb: 96
  estimated_duration_minutes: 40
  allocation_reason: large_data_requires_dwe_for_sla
  resource_metadata:
    provider: gcp
    provider_selection_reason: system_default_provider
    compute_class: standard-memory-optimized
    region: us-central1
```

Example 3: Vendor-Cloud (Provider Constraint Unsupported) — Reject

```
Input:
  solution: migration
  estimated_data_size_gb: 500
  desired_sla_minutes: 60
  deployment_mode: vendor_cloud_data_plane
  provider_constraint: aws_only
  authorized_capabilities: [serial, internal_parallelism]

Policy:
  default_provider: gcp
  supported_providers: [gcp]

Processing:
  provider_constraint: aws_only
  → Check: aws not in supported_providers
  → REJECT: RESOURCE_PROVIDER_UNSUPPORTED

Output:
  Error: "Provider constraint 'aws_only' cannot be satisfied. Supported providers: [gcp]"
  Plan freeze blocked
  Event: RESOURCE_PROVIDER_UNSUPPORTED emitted
```

Example 4: Vendor-Cloud (Provider Preference, but Unsupported) — Fallback to GCP

```
Input:
  solution: migration
  estimated_data_size_gb: 1500
  desired_sla_minutes: 45
  deployment_mode: vendor_cloud_data_plane
  provider_preference: aws
  authorized_capabilities: [serial, internal_parallelism, dwe]

Policy:
  default_provider: gcp
  supported_providers: [gcp]

Processing:
  provider_preference: aws (advisory, not constraint)
  → selected_provider: gcp (system default)

Output:
  mode: resource_intent_reservation
  selected_execution_mode: dwe
  reserved_workers: 24
  reserved_memory_gb: 96
  estimated_duration_minutes: 40
  resource_metadata:
    provider: gcp
    provider_selection_reason: system_default_provider (preference_not_supported)
```

Example 5: Vendor-Cloud (Provider Constraint Supported)

```
Input:
  solution: migration
  estimated_data_size_gb: 1500
  desired_sla_minutes: 45
  deployment_mode: vendor_cloud_data_plane
  provider_constraint: gcp_only
  authorized_capabilities: [serial, internal_parallelism, dwe]

Policy:
  default_provider: gcp
  supported_providers: [gcp]

Processing:
  provider_constraint: gcp_only
  → Check: gcp in supported_providers → allowed
  → selected_provider: gcp

Output:
  mode: resource_intent_reservation
  selected_execution_mode: dwe
  reserved_workers: 24
  reserved_memory_gb: 96
  estimated_duration_minutes: 40
  resource_metadata:
    provider: gcp
    provider_selection_reason: customer_contract_constraint
```

---

Appendix C — Implementation Depth (v0.2.2)

Component Implementation
Resource Request Contract Define interface
Resource Plan Contract Define interface
Resource Provider Abstraction Define interface
GCP Provider Default implementation (stub)
AWS Provider Interface only (future)
Azure Provider Interface only (future)
On-Prem Provider Interface only (future)
Provider Selection Policy Basic policy stub (GCP default)
Provider Constraint Handling Validation stub (reject unsupported)
Provider Fallback Not implemented (no fallback)
Customer-Cloud Metadata Accepted as context only
Execution Mode Selection Deterministic planner stub
Customer-Cloud Recommendation Basic logic only
Vendor-Cloud Reservation Interface only
Physical Provisioning Not implemented
Cloud API Integration Not implemented

---

Appendix D — Future Extensibility

FR-040 is designed for future extension without modification:

Future Resource Types:

· GPU allocation
· FPGA allocation
· Spot/on-demand instance selection
· Multi-region allocation
· Priority-based preemption

Future Providers:

· AWS (EKS, EC2)
· Azure (AKS, VMs)
· On-Premise (bare metal, private cloud)
· Hybrid (multi-provider)

Future Policies:

· Cost optimization
· Carbon footprint optimization
· Reserved instance utilization
· Burst capacity
· Provider priority ordering
· Regional failover

Future Provider Selection:

· Cost-based provider selection
· Capacity-based provider selection
· Latency-based provider selection
· Compliance-based provider selection
· Multi-provider fallback (when policy permits)

Future Metrics:

· Actual vs estimated comparison
· Resource utilization feedback
· SLA achievement tracking

Future Provisioning:

· Kubernetes operator integration
· Cloud provider SDK integration
· Terraform/Infrastructure-as-Code integration

Future Fallback Behavior:

· Policy-controlled fallback to default provider
· Multi-provider availability zones
· Automatic provider failover

```
```