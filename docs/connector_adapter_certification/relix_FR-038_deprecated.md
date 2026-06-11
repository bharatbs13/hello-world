# FR-038 — Additional Adapter Implementations

## Phase

**v0.2.2**

## Objective

Expand the adapter ecosystem supported by Relix through the implementation of additional adapter integrations that conform to the Universal Connector Adapter Framework defined by FR-034.

FR-038 introduces additional adapter implementations only.

FR-038 does **NOT** introduce new adapter framework behavior, connector resolution policies, lifecycle semantics, governance rules, execution semantics, or security capabilities.

All adapter framework behavior remains governed by FR-034.

---

## Scope

FR-038 introduces the following adapter implementations:

- AirbyteConnectorAdapter
- SingerMeltanoConnectorAdapter

Including:

- adapter registration
- connector capability mapping
- connector resolution participation
- preflight validation participation
- execution lifecycle participation
- recovery lifecycle participation
- reconciliation lifecycle participation

Both adapters SHALL conform to the adapter contract established by FR-034.

---

## Inherited Behavior

FR-038 inherits all framework behavior defined by FR-034, including:

- adapter registration model
- connector resolution model
- connector selection policies
- capability mapping semantics
- runtime isolation requirements
- failure translation requirements
- security requirements
- optional dependency packaging model

FR-038 introduces adapter implementations only.

---

## Initial Implementation

### AirbyteConnectorAdapter

Provides Relix integration with connector ecosystems supported through Airbyte.

The adapter SHALL:

- participate in connector resolution
- expose connector capabilities through the FR-034 capability model
- support Relix connector interface requirements
- integrate with Relix preflight validation

### SingerMeltanoConnectorAdapter

Provides Relix integration with connector ecosystems supported through Singer and Meltano.

The adapter SHALL:

- participate in connector resolution
- expose connector capabilities through the FR-034 capability model
- support Relix connector interface requirements
- integrate with Relix preflight validation

---

## Non-Goals

FR-038 does **NOT** introduce:

- new adapter framework capabilities
- new adapter lifecycle semantics
- new connector resolution policies
- adapter orchestration changes
- distributed adapter execution
- adapter discovery services
- adapter marketplaces
- adapter-specific governance models
- adapter-specific security models
- adapter-specific access control models
- new permission models
- runtime execution model changes
- checkpoint model changes
- reconciliation model changes

Such capabilities remain governed by FR-034 or future FRs.

---

## Architectural Position

```text
FR-025 — Connector Integration & Expansion Framework
                ↓
FR-034 — Universal Connector Adapter Framework
                ↓
FR-038 — Additional Adapter Implementations
                ↓

    AirbyteConnectorAdapter
    SingerMeltanoConnectorAdapter
```

```text
FR-034
 ├── DltConnectorAdapter              (v0.2.1)
 ├── AirbyteConnectorAdapter          (FR-038)
 └── SingerMeltanoConnectorAdapter    (FR-038)
```

FR-038 extends the set of available adapter implementations while preserving the framework established by FR-034.

---

## Integration with FR-034

AirbyteConnectorAdapter and SingerMeltanoConnectorAdapter SHALL:

- register through the FR-034 adapter registry
- participate in FR-034 connector resolution
- honor FR-034 connector selection policies
- expose connector capability declarations
- participate in FR-034 preflight validation
- support FR-034 freeze-time resolution semantics
- support FR-034 recovery guarantees
- support FR-034 replay guarantees
- support FR-034 reconciliation guarantees

FR-038 SHALL NOT modify FR-034 framework behavior.

---

## Determinism Requirements

Adapter implementations introduced by FR-038 SHALL preserve all deterministic guarantees established by:

- FR-026 Runtime & Execution Framework
- FR-028 Checkpoint Recovery Framework
- FR-029 Reconciliation Runtime Framework
- FR-034 Universal Connector Adapter Framework

Resolved adapter implementations MUST remain stable for the lifetime of a frozen execution plan.

Adapter behavior MUST NOT weaken or bypass:

- execution plan freeze semantics
- checkpoint recovery semantics
- replay validation semantics
- reconciliation semantics

---

## Validation Requirements

The adapter implementations introduced by FR-038 SHALL successfully participate in:

- connector registration
- connector resolution
- capability declaration validation
- preflight validation
- execution plan freeze
- execution lifecycle processing
- checkpoint recovery
- replay validation
- reconciliation processing

No modifications to FR-034 framework behavior SHALL be required to support the adapters introduced by FR-038.

---

## Acceptance Criteria

FR-038 is complete when:

- AirbyteConnectorAdapter is implemented
- SingerMeltanoConnectorAdapter is implemented
- Both adapters register successfully through the FR-034 adapter registry
- Both adapters participate in connector resolution
- Both adapters expose capability declarations required by FR-034
- Both adapters successfully participate in preflight validation
- Both adapters successfully participate in execution plan freeze
- Both adapters successfully participate in execution processing
- Both adapters successfully participate in checkpoint recovery
- Both adapters successfully participate in replay validation
- Both adapters successfully participate in reconciliation processing
- Existing FR-034 framework behavior operates without modification
- No new adapter framework capability is introduced
- No FR-034 framework changes are required to support either adapter

---

## Deferred Items

The following remain outside the scope of FR-038:

- adapter marketplace functionality
- adapter auto-discovery
- distributed adapter execution
- adapter orchestration enhancements
- adapter federation
- adapter failover policies
- adapter-specific governance extensions
- adapter-specific access control extensions
- adapter performance optimization features

---

## Runtime Guarantees Preserved

FR-038 MUST NOT weaken or bypass:

- FR-026 Runtime & Execution Framework
- FR-028 Checkpoint Recovery Framework
- FR-029 Reconciliation Runtime Framework
- FR-034 Universal Connector Adapter Framework

The adapter implementations introduced by FR-038 inherit all runtime guarantees established by those frameworks.

---

## References

| FR | Description |
|----|-------------|
| FR-025 | Connector Integration & Expansion Framework |
| FR-026 | Runtime & Execution Framework |
| FR-028 | Checkpoint Recovery Framework |
| FR-029 | Reconciliation Runtime Framework |
| FR-034 | Universal Connector Adapter Framework |

