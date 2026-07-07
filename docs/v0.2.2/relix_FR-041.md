# FR-041 — Customer Data Plane Connectivity Validation

## Status
Approved

## Target Product Version
v0.2.2 (or later)

## Objective
Provide connectivity validation for customer-cloud data planes, enabling Relix to verify reachability and health of customer-deployed agents before freezing execution plans.

The framework shall validate control-plane to customer data-plane connectivity for customer-cloud deployment mode only. Vendor-cloud data planes shall skip this validation.

The objective is execution readiness, not network provisioning.

---

## Scope

### Owns
- control-plane to customer data-plane ping
- agent health check
- reachability status
- latency measurement
- connectivity status (PASS / FAIL / UNKNOWN)
- freeze blocking when validation fails
- connectivity validation events
- connectivity audit metadata

### Does Not Own
- VPN setup
- VPC peering
- firewall configuration
- cloud networking
- IAM setup
- inter-cloud provisioning
- Kubernetes provisioning
- actual resource allocation (see FR-040)
- license authorization (see FR-038A)

---

## Relationship to FR-038A, FR-038B, and FR-040

FR-038A owns license authorization (Gate 1).

FR-040 owns resource allocation (Gate 2).

FR-041 owns connectivity validation (Gate 3, conditional).

```

Request
↓
Gate 1: FR-038A — License Authorization
↓
Gate 2: FR-040 — Resource Allocation Contract
↓
Gate 3: FR-041 — Connectivity Validation (conditional)
↓
Plan Freeze
↓
Execution

```

FR-041 shall only execute when deployment_mode = customer_cloud_data_plane.

FR-041 shall be skipped when deployment_mode = vendor_cloud_data_plane.

---

## Principles

### Conditional Execution
FR-041 shall only run for customer-cloud data plane mode.

Vendor-cloud data planes shall skip connectivity validation.

### Validation Only
FR-041 shall validate connectivity but shall not establish connectivity.

Network setup, VPN configuration, and firewall rules are out of scope.

### Freeze Blocking
Connectivity validation failure shall block plan freeze.

Connectivity validation PASS shall allow plan freeze to proceed.

Connectivity validation UNKNOWN shall follow configured policy.

---

## Validation Contract

### Input
```

ConnectivityRequest:
data_plane_id: string
data_plane_endpoint: string
deployment_mode: customer_cloud_data_plane | vendor_cloud_data_plane
timeout_ms: integer
retry_count: integer
retry_interval_ms: integer

```

### Example
```json
{
  "data_plane_id": "dp-customer-123",
  "data_plane_endpoint": "https://customer-agent.example.com:8443/health",
  "deployment_mode": "customer_cloud_data_plane",
  "timeout_ms": 5000,
  "retry_count": 3,
  "retry_interval_ms": 1000
}
```

Output

```
ConnectivityResult:
  status: PASS | FAIL | UNKNOWN | SKIPPED
  latency_ms: integer (optional)
  agent_version: string (optional)
  agent_health: healthy | degraded | unhealthy
  validation_timestamp: timestamp
  failure_reason: string (optional)
  retry_attempts: integer
  skip_reason: string (optional)
```

Example — PASS

```json
{
  "status": "PASS",
  "latency_ms": 45,
  "agent_version": "v0.2.2",
  "agent_health": "healthy",
  "validation_timestamp": "2027-01-01T00:00:00Z",
  "retry_attempts": 0
}
```

Example — FAIL

```json
{
  "status": "FAIL",
  "validation_timestamp": "2027-01-01T00:00:00Z",
  "failure_reason": "connection_timeout",
  "retry_attempts": 3
}
```

Example — UNKNOWN

```json
{
  "status": "UNKNOWN",
  "validation_timestamp": "2027-01-01T00:00:00Z",
  "failure_reason": "agent_responding_but_unhealthy",
  "retry_attempts": 2
}
```

Example — SKIPPED

```json
{
  "status": "SKIPPED",
  "validation_timestamp": "2027-01-01T00:00:00Z",
  "skip_reason": "vendor_cloud_data_plane",
  "retry_attempts": 0
}
```

---

Configuration Policy

FR-041 shall support configurable policy for UNKNOWN status.

Policy Options:

· block — treat as FAIL, block plan freeze
· allow_with_warning — allow plan freeze with warning
· allow_if_previous_known_good — allow if last known status was PASS

---

UAT Testing Strategy

FR-041 shall be testable in UAT without real inter-cloud network setup.

Test Environment:

· Mock customer data-plane endpoint
· Test agent with configurable health states
· Controlled network conditions

UAT Test Cases:

Test Expected
Connectivity PASS Plan freeze allowed
Connectivity FAIL Plan freeze blocked
Connectivity UNKNOWN Follows configured policy
Vendor-cloud mode FR-041 skipped, SKIPPED event emitted
Customer-cloud mode FR-041 runs
Event emitted CONNECTIVITY_VALIDATION_* events
Retry succeeds PASS after retry
Retry fails FAIL after retries exhausted

---

Observability

FR-041 shall emit connectivity validation events.

Events:

· CONNECTIVITY_VALIDATION_STARTED
· CONNECTIVITY_VALIDATION_PASSED
· CONNECTIVITY_VALIDATION_FAILED
· CONNECTIVITY_VALIDATION_UNKNOWN
· CONNECTIVITY_VALIDATION_SKIPPED
· CONNECTIVITY_VALIDATION_RETRY

---

Audit Metadata

Connectivity decisions shall be auditable.

Audit metadata may include:

· data_plane_id
· data_plane_endpoint
· status
· latency_ms
· agent_version
· agent_health
· validation_timestamp
· failure_reason
· retry_attempts
· policy_applied
· skip_reason

---

Failure Handling

Connectivity failures shall fail safely.

If connectivity validation fails:

· Actionable error shall be emitted
· Failure shall be observable
· Plan freeze shall be blocked
· License and resource allocation state shall remain unaffected

---

Acceptance Criteria

AC# Description
AC1 Relix shall validate connectivity for customer-cloud data planes.
AC2 Relix shall skip connectivity validation for vendor-cloud data planes.
AC3 Relix shall support PASS, FAIL, UNKNOWN, and SKIPPED connectivity statuses.
AC4 Relix shall support configurable policy for UNKNOWN status.
AC5 Connectivity PASS shall allow plan freeze to proceed.
AC6 Connectivity FAIL shall block plan freeze.
AC7 Relix shall retry connectivity validation according to configured retry policy.
AC8 Relix shall emit connectivity validation events including SKIPPED for vendor-cloud mode.
AC9 Relix shall maintain audit trail of connectivity validation attempts.
AC10 FR-041 shall not implement VPN setup, VPC peering, or cloud networking.
AC11 FR-041 shall be UAT-testable without real inter-cloud network setup.

---

Design Rule

Connectivity validation is a conditional gate, not a network provisioning service.

FR-041 validates that Relix can reach customer data-plane agents.

FR-041 does not establish or configure network connectivity.

Customer-cloud data planes require connectivity validation.

Vendor-cloud data planes skip connectivity validation with SKIPPED event for audit.

Connectivity validation is the third gate, after license authorization and resource allocation.

---

Appendix A — Integration Architecture

Conditional Gate Flow

```
Resource Plan Generated (FR-040)
        ↓
deployment_mode check
        ↓
┌──────────────────────┐     ┌──────────────────────┐
│  customer_cloud      │     │  vendor_cloud        │
│  data_plane          │     │  data_plane          │
└──────────┬───────────┘     └──────────┬───────────┘
           │                            │
           ▼                            ▼
  ┌─────────────────┐          ┌─────────────────┐
  │  FR-041         │          │  SKIP           │
  │  Connectivity   │          │  Emit SKIPPED   │
  │  Validation     │          │  event          │
  └────────┬────────┘          └─────────────────┘
           │                            │
  ┌────────┴────────┐                   │
  │ PASS   │  FAIL  │                   │
  ▼        ▼        ▼                   ▼
Plan    Block    Policy              Plan Freeze
Freeze            apply              (direct)
```

---

Appendix B — UAT Test Examples

Test 1: Connectivity PASS

```
Given: mock agent responding with 200 OK
When: FR-041 validation runs
Then: status = PASS
And: plan freeze proceeds
And: CONNECTIVITY_VALIDATION_PASSED event emitted
```

Test 2: Connectivity FAIL

```
Given: mock agent unreachable (timeout)
When: FR-041 validation runs with retry_count = 3
Then: status = FAIL
And: plan freeze blocked
And: CONNECTIVITY_VALIDATION_FAILED event emitted
And: failure_reason = connection_timeout
And: retry_attempts = 3
```

Test 3: Connectivity UNKNOWN — block policy

```
Given: mock agent responding but health = degraded
When: FR-041 validation runs
Then: status = UNKNOWN
And: policy = block
And: plan freeze blocked
And: CONNECTIVITY_VALIDATION_UNKNOWN event emitted
```

Test 4: Connectivity UNKNOWN — allow_with_warning policy

```
Given: mock agent responding but health = degraded
And: policy = allow_with_warning
When: FR-041 validation runs
Then: status = UNKNOWN
And: plan freeze proceeds with warning
And: warning emitted in audit log
```

Test 5: Vendor-cloud mode skip

```
Given: deployment_mode = vendor_cloud_data_plane
When: FR-041 validation check runs
Then: validation skipped
And: status = SKIPPED
And: skip_reason = vendor_cloud_data_plane
And: plan freeze proceeds directly
And: CONNECTIVITY_VALIDATION_SKIPPED event emitted
```

---

Appendix C — Implementation Depth (v0.2.2)

Component Implementation
Connectivity Request Contract Define interface
Connectivity Result Contract Define interface
Validation Logic Mock validator only
Retry Logic Basic retry implementation
UNKNOWN Policy Configurable policy stub
Actual Network Ping Not implemented
Cloud Network APIs Not implemented
Real Agent Health Check Not implemented

---

Appendix D — Future Extensibility

FR-041 is designed for future extension without modification:

Future Validation Types:

· TLS certificate validation
· Mutual TLS validation
· Token-based authentication
· Customer agent version compatibility
· Custom health check endpoints

Future UAT Capabilities:

· Network latency simulation
· Partial connectivity scenarios
· Service degradation testing
· Failover testing
· Multi-region connectivity testing

Future Validation Methods:

· gRPC health checks
· WebSocket connectivity
· Message queue reachability
· Storage endpoint accessibility
