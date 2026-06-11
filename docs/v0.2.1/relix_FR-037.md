# FR-037 — Transport Encryption Validation Framework

## Phase

v0.2.1

## Objective

Provide transport encryption configuration, validation, and enforcement for connector-based data movement within Relix.

FR-037 ensures that connector transport may be configured to require encrypted communication and that execution is blocked when required transport security conditions are not satisfied.

FR-037 is an independent connector governance capability. It validates transport security requirements for connector execution. It does not depend on access profile or binding frameworks.

---

## Scope

FR-037 introduces:

- transport security configuration
- connector transport capability declaration
- TLS/SSL enforcement
- transport validation during preflight
- transport-related execution blocking
- transport security event reporting

FR-037 applies to:

- native connectors
- adapter-backed connectors
- future connector implementations

---

## Non-Goals

FR-037 does **NOT** introduce:

- enterprise key management
- certificate lifecycle management
- certificate issuance
- certificate rotation
- secrets governance
- policy-as-code security engines
- compliance frameworks
- data-at-rest encryption
- field-level encryption

Those capabilities are deferred to future enterprise security phases.

---

## Architectural Position

FR-037 is an independent connector governance capability.

Transport security is orthogonal to access control.

A connector may be:

- TLS enabled + read_only
- TLS enabled + admin
- TLS disabled + read_only
- TLS disabled + admin

FR-037 governs transport security.

Access profiles govern operational permissions.

These are separate concerns.

---

## Architectural Principle

Transport security validation is an independent connector governance capability.

It applies uniformly to connector execution regardless of connector implementation, access profile configuration, or future usage.

---

## Connector Transport Capabilities

Connectors **MAY** expose the following transport security capabilities:

| Capability | Description |
|------------|-------------|
| transport_encryption | Connector supports encrypted transport |
| certificate_validation | Connector can validate server certificates |

Capability declarations **MUST** be exposed through connector metadata.

---

## Configuration

### Transport Security Configuration

Transport security is configured per connector.

#### Example

```yaml
connector:
  transport_security:
    sslmode: require
    verify_certificate: true
```

Configuration is validated during preflight and enforced during connection establishment.

---

## Supported Transport Modes

### Generic Modes

| Mode | Description |
|--------|-------------|
| disable | Transport encryption disabled |
| allow | Encryption optional, no certificate validation |
| prefer | Attempt encryption when available, fall back to unencrypted |
| require | Encrypted transport mandatory, no certificate validation |
| verify-ca | Encrypted transport mandatory, CA validation required |
| verify-full | Encrypted transport mandatory, full certificate validation required |

Connector implementations **MAY** support a subset of these modes.

Unsupported modes **MUST** fail during preflight validation.

---

## Connector Responsibilities

Connector implementations **MUST**:

- accept transport security configuration
- apply transport configuration during connection creation
- expose transport capabilities through connector metadata
- report transport failures as Relix runtime errors
- expose effective transport state when available

Connector implementations **MUST NOT**:

- silently downgrade required encryption
- bypass certificate validation when configured
- expose raw driver-specific TLS exceptions beyond connector boundaries

---

## PostgreSQL Transport Requirements

PostgreSQL connectors **MUST** support all generic transport modes:

- disable
- allow
- prefer
- require
- verify-ca
- verify-full

Implementation **MUST** use native PostgreSQL SSL/TLS support.

Other native connectors **MAY** support a subset of modes appropriate to their driver capabilities.

---

## Preflight Integration

Preflight **MUST** validate:

- connector transport requirements
- configured transport mode support against connector capabilities
- certificate validation requirements against connector capabilities
- connector transport capability compatibility

### Validation Flow

```text
Transport Security Configuration
      ↓
Connector Transport Capabilities
      ↓
Mode Support Check
      ↓
Certificate Validation Check
      ↓
Pass / Fail
```

---

## Blocking Rules

Execution **MUST** be blocked when:

| Condition | Result |
|------------|---------|
| Configured transport mode requires encryption but connector does not support `transport_encryption` | BLOCKED |
| Encrypted transport is required but configured transport mode is `disable` | BLOCKED |
| Certificate validation required but connector does not support `certificate_validation` | BLOCKED |
| Configured mode is not supported by connector | BLOCKED |
| Transport configuration is invalid or malformed | BLOCKED |

---

## Successful Validation

Execution **MAY** continue when:

| Condition | Result |
|------------|---------|
| Transport requirements fully satisfied | PASSED |
| Transport is optional and available | PASSED |
| Transport is optional and unavailable but not required | PASSED |

---

## Runtime Enforcement

Execution engines **MUST NOT** bypass validated transport requirements.

If transport security requirements can no longer be satisfied after preflight (e.g., certificate expiry, certificate validation failure, transport downgrade), execution **MUST** fail with an explicit transport error.

Runtime transport failures **MUST NOT** corrupt:

- execution state
- checkpoint data
- reconciliation metadata
- event ordering

---

## Events

The framework **SHOULD** emit events for:

- `TRANSPORT_VALIDATION_STARTED`
- `TRANSPORT_VALIDATION_PASSED`
- `TRANSPORT_VALIDATION_FAILED`
- `TRANSPORT_ENCRYPTION_REQUIRED`
- `TRANSPORT_ENCRYPTION_DISABLED`

Event names may be mapped into existing runtime event structures.

---

## Error Semantics

Transport failures **MUST** be translated into Relix runtime errors.

Raw driver-specific TLS exceptions **MUST NOT** propagate beyond connector boundaries.

### Example Errors

```text
ERROR: Transport encryption is required but connector
"postgres_production" is configured with sslmode "disable".
```

```text
ERROR: Connector "mysql_legacy" does not support transport
encryption. Mode "require" is not available for this connector.
```

```text
ERROR: Certificate validation failed for connector
"postgres_production". The server certificate could not be
verified against the configured CA.
```

---

## Determinism Requirements

FR-037 **MUST NOT** alter:

- execution determinism
- checkpoint semantics
- reconciliation semantics
- event ordering guarantees

Transport validation is a gating mechanism only.

Once validation passes, execution proceeds with the same deterministic guarantees.

---

## Native Connectors

Native connectors **MUST** honor transport security configuration.

Failure to satisfy required transport security **MUST** prevent execution.

Native connectors **MUST** expose transport capabilities through the standard connector metadata interface.

---

## Adapter-Backed Connectors

Adapter-backed connectors **MUST** expose transport configuration through Relix governance layers.

Transport enforcement **MUST** remain Relix-controlled.

Adapters **MUST NOT** independently decide transport security policy.

Adapter-backed connectors **MUST** declare transport capabilities through the same capability metadata interface used by native connectors.

---

## Acceptance Criteria

FR-037 is complete when:

- Transport security configuration exists
- Connector capabilities expose transport support:
  - `transport_encryption`
  - `certificate_validation`
- PostgreSQL connectors support all six generic transport modes
- Preflight validates transport requirements against connector capabilities
- Insecure connections are rejected when encryption is required
- Unsupported transport modes fail during preflight
- Transport failures generate Relix runtime errors, not raw driver exceptions
- Transport validation failures block execution
- Transport validation success allows execution to proceed
- Runtime transport failures do not corrupt execution state, checkpoints, or reconciliation metadata
- Transport events are emitted into the runtime event stream
- Adapter-backed connectors expose transport configuration through Relix governance
- Transport enforcement remains Relix-controlled for all connector types
- Integration tests validate both secure and insecure execution paths
- FR-037 operates independently of access profile and binding frameworks
- FR-037 contains no solution-specific concepts

---

## Deferred Items

The following are deferred beyond FR-037:

- enterprise PKI integration
- certificate lifecycle management
- certificate issuance
- certificate rotation
- HSM integration
- cloud KMS integration
- security policy engines
- compliance reporting
- data-at-rest encryption
- field-level encryption

---

## Runtime Guarantees Preserved

Transport encryption validation **MUST NOT** weaken or bypass:

- checkpoint recovery semantics
- reconciliation semantics
- execution determinism
- event ordering guarantees

---

## References

- FR-026 Runtime & Execution Framework
- FR-033 Preflight Workflow Framework
