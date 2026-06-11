# FR-037 — Transport Encryption Validation Framework

## Phase

`v0.2.1`

## Objective

Provide transport encryption configuration, validation, and enforcement for connector-based data movement within Relix.

FR-091 ensures that source and destination connections may be configured to require encrypted transport and that execution is blocked when required transport security conditions are not satisfied.

The purpose of FR-091 is to validate encrypted transport during connector execution while preserving existing runtime, connector, and preflight architecture.

---

## Scope

FR-037 introduces:

* transport security configuration
* connector transport capability declaration
* TLS/SSL enforcement
* transport validation during preflight
* transport-related execution blocking
* transport security event reporting

FR-037 applies to:

* native connectors
* `dlt`-backed connectors
* future connector implementations

---

## Non-Goals

FR-037 does NOT introduce:

* enterprise key management
* certificate lifecycle management
* certificate issuance
* certificate rotation
* secrets governance
* policy-as-code security engines
* compliance frameworks
* data-at-rest encryption

Those capabilities are deferred to future enterprise security phases.

---

## Architectural Principle

```text
Transport security is a connector capability
validated by preflight and enforced during execution.
```

---

## Connector Capabilities

Connectors MAY expose the following capabilities:

* `TRANSPORT_ENCRYPTION`
* `TLS_REQUIRED`
* `CERTIFICATE_VALIDATION`

Capability declarations MUST be exposed through connector metadata.

---

## Configuration

### Example

```yaml
connector:
  transport_security:
    sslmode: require
    verify_certificate: true
```

---

## Supported Transport Modes

### Generic Modes

| Mode | Description |
|--------|-------------|
| `disable` | transport encryption disabled |
| `allow` | encryption optional |
| `prefer` | attempt encryption when available |
| `require` | encrypted transport mandatory |
| `verify-ca` | encrypted transport + CA validation |
| `verify-full` | encrypted transport + full certificate validation |

Connector implementations MAY support a subset of these modes.

Unsupported modes MUST fail during preflight.

---

## Connector Responsibilities

Connector implementations MUST:

* accept transport security configuration
* apply transport configuration during connection creation
* expose transport capabilities
* report transport failures
* expose effective transport state when available

---

## PostgreSQL Requirements

PostgreSQL connectors MUST support:

* `disable`
* `allow`
* `prefer`
* `require`
* `verify-ca`
* `verify-full`

using native PostgreSQL SSL/TLS support.

---

## Preflight Integration

FR-033 preflight MUST validate:

* source transport requirements
* destination transport requirements
* configured transport mode support
* certificate validation requirements
* connector capability compatibility

---

## Blocking Rules

Execution MUST be blocked when:

| Condition | Result |
|------------|----------|
| TLS required but disabled | BLOCKED |
| TLS required but unsupported | BLOCKED |
| certificate validation required but unavailable | BLOCKED |
| transport configuration invalid | BLOCKED |

---

## Successful Validation

Execution MAY continue when:

| Condition | Result |
|------------|----------|
| transport requirements satisfied | PASSED |
| transport optional and available | PASSED |
| transport optional and unavailable | PASSED |

---

## Runtime Enforcement

Execution engines MUST NOT bypass validated transport requirements.

If connector transport validation fails after preflight, execution MUST fail.

---

## Events

The framework SHOULD emit events for:

* `TRANSPORT_VALIDATION_STARTED`
* `TRANSPORT_VALIDATION_PASSED`
* `TRANSPORT_VALIDATION_FAILED`
* `TRANSPORT_ENCRYPTION_REQUIRED`

Event names may be mapped into existing runtime event structures.

---

## Error Semantics

Transport failures MUST be translated into Relix runtime errors.

Raw driver-specific TLS exceptions SHOULD NOT propagate beyond connector boundaries.

---

## Determinism Requirements

FR-091 MUST NOT alter:

* execution determinism
* checkpoint semantics
* reconciliation semantics
* workflow state transitions
* event ordering guarantees

Transport validation is a gating mechanism only.

---

## Native Connectors

Native connectors MUST honor transport security configuration.

Failure to satisfy required transport security MUST prevent execution.

---

## `adaptor`-backed Connectors

`adaptor`-backed connectors MUST expose transport configuration through Relix governance layers.

Transport enforcement MUST remain Relix-controlled.

---

## Acceptance Criteria

FR-037  is complete when:

* transport configuration exists
* connector capabilities expose transport support
* PostgreSQL connectors support TLS configuration
* preflight validates transport requirements
* insecure connections are rejected when encryption is required
* transport failures generate runtime errors
* integration tests validate secure and insecure execution paths

---

## Deferred Items

The following are deferred:

* enterprise PKI integration
* certificate lifecycle management
* certificate rotation
* HSM integration
* cloud KMS integration
* security policy engines
* compliance reporting
* data-at-rest encryption
* field-level encryption

---

