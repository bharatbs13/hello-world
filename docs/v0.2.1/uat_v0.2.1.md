# Relix v0.2.1 Functional UAT Specification

## 1. Scope

Functional UAT only.

### Covers

- adapter-backed connector support
- access profile framework
- connector-profile binding
- transport encryption validation

### Excludes

- performance testing
- load testing
- security penetration testing
- infrastructure benchmarking
- compliance certification
- UI validation

---

## 2. Common Environment Setup

- Relix runtime deployed
- preflight enabled
- PostgreSQL available as native connector
- Snowflake available as adapter-backed connector
- limited-capability connector available for negative capability tests
- connector registry configured
- supported connector registry configured with postgres, snowflake, and limited-capability connector enabled
- adapter registry configured with at least one adapter enabled
- connector selection policy set to `native_preferred`
- access profiles configured:
  - `read_only`
  - `read_metadata`
  - `read_write`
  - `read_write_ddl`
  - `admin`
- connector bindings configured
- transport security test endpoints with valid and invalid TLS certificates
- non-TLS connector endpoint available for optional transport fallback tests
- test credentials available through Relix credential provider
- event store enabled
- checkpoint store enabled
- reconciliation metadata store enabled

---

## 3. Test Case ID Convention

```text
UAT-V021-FUNC-<CLASS>-<NNN>
```

---

## 4. Test Class Convention

| Class | Description |
|---------|---------|
| ADAPTER | Adapter-backed connector resolution and execution |
| ACCESS_PROFILE | Access profile definition, validation, and lifecycle |
| BINDING | Connector-to-profile binding and enforcement |
| TRANSPORT | Transport encryption validation and enforcement |
| PREFLIGHT | Preflight validation across all governance capabilities |
| RUNTIME_ENFORCEMENT | Runtime permission and transport enforcement |
| FREEZE_STABILITY | Immutability guarantees for frozen execution plans |
| ERROR_SEMANTICS | Error translation and propagation boundaries |

---

## 5. Test Case Format

### `<TEST_ID>` — `<Short Test Name>`

**Class:** `<CLASS>`

**Condition:**  
What must be configured or triggered.

**Description:**  
What behavior is being validated.

**Acceptance Criteria**

- Expected result 1
- Expected result 2
- Expected error/event if applicable

---

## 6. Adapter Coverage Rule

Adapter-backed connector test cases are framework-level test cases.

The same test case **MUST** be executed against all supported and enabled adapters available in the test environment.

The test case ID remains unchanged.

Concrete adapter execution is tracked by the automation framework using execution metadata such as adapter name, connector type, and execution run ID.

UAT descriptions **SHOULD** use adapter-neutral wording such as:

- supported adapter-backed connector
- enabled adapter-backed implementation
- adapter-backed connector implementation

UAT descriptions **SHOULD NOT** hard-code `DltConnectorAdapter` unless the test case is explicitly validating `DltConnectorAdapter` itself.

### Example

```text
Test Case:
  UAT-V021-FUNC-ADAPTER-004

Execution Variants:
  adapter=dlt
  adapter=future_adapter_a
  adapter=future_adapter_b

The UAT identifier remains unchanged.
Execution identifiers distinguish concrete adapter runs.
```

---

# UAT Area 1 — Adapter-Backed Connector Support

## Positive Functional Cases

### UAT-V021-FUNC-ADAPTER-001 — Native Connector Selected When Available

**Class:** ADAPTER

**Condition**  
Postgres connector exists as both native implementation and adapter-backed implementation. Connector selection policy is `native_preferred`.

**Description**  
Validate that the native connector implementation is selected when both native and adapter-backed implementations exist.

**Acceptance Criteria**

- Connector resolution returns the native `PostgresConnector` implementation
- Adapter-backed implementation is not selected
- Preflight validation passes
- Native connector is used for execution

---

### UAT-V021-FUNC-ADAPTER-002 — Adapter-Backed Connector Selected When Native Unavailable

**Class:** ADAPTER

**Condition**  
Snowflake connector exists only as an adapter-backed implementation. No native Snowflake connector exists.

**Description**  
Validate that connector resolution selects the adapter-backed implementation when no native connector is available.

**Acceptance Criteria**

- Connector resolution returns the enabled adapter-backed implementation for Snowflake
- Preflight validation passes
- Connector supports all required interface methods

---

### UAT-V021-FUNC-ADAPTER-003 — Enabled Adapter Participates in Connector Resolution

**Class:** ADAPTER

**Condition**  
An adapter is enabled in the adapter registry.

**Description**  
Validate that an enabled adapter is considered during connector resolution.

**Acceptance Criteria**

- Enabled adapter appears as an available implementation
- Connectors supported by the enabled adapter are resolvable
- Resolution succeeds for adapter-supported connectors

---

### UAT-V021-FUNC-ADAPTER-004 — Adapter-Backed Connector Supports Read Connectivity

**Class:** ADAPTER

**Condition**  
An enabled adapter-backed connector implementation resolved for Snowflake with read capability.

**Description**  
Validate that an adapter-backed connector can establish connectivity and read data.

**Acceptance Criteria**

- `connect()` succeeds
- `validate_connectivity()` passes
- `discover_schema()` returns schema information
- `read_batch()` returns expected data
- `disconnect()` succeeds

---

### UAT-V021-FUNC-ADAPTER-005 — Adapter-Backed Connector Supports Write Connectivity

**Class:** ADAPTER

**Condition**  
An enabled adapter-backed connector implementation resolved for Snowflake with write capability.

**Description**  
Validate that an adapter-backed connector can establish connectivity and write data.

**Acceptance Criteria**

- `connect()` succeeds
- `validate_connectivity()` passes
- `begin_batch()` succeeds
- `write_batch()` writes expected data
- `commit_batch()` succeeds
- `disconnect()` succeeds
- Written data is verifiable through the connector

---

### UAT-V021-FUNC-ADAPTER-006 — Adapter-Backed Execution Completes Successfully

**Class:** ADAPTER

**Condition**  
Full execution plan frozen using an adapter-backed connector for Snowflake. Plan includes read and write operations.

**Description**  
Validate functional execution using an adapter-backed connector.

**Acceptance Criteria**

- Execution plan freeze succeeds
- Execution completes without errors
- All batches are processed
- Checkpoint is written successfully
- Reconciliation metadata is consistent

---

### UAT-V021-FUNC-ADAPTER-007 — Supported Connector Registry Allows Enabled Connector

**Class:** ADAPTER

**Condition**  
Snowflake is enabled in the Supported Connector Registry. An enabled adapter supports Snowflake.

**Description**  
Validate that a connector enabled in the Supported Connector Registry is available when an adapter supports it.

**Acceptance Criteria**

- Snowflake connector is available for resolution
- Resolution returns the enabled adapter-backed implementation
- Preflight validation passes

---

### UAT-V021-FUNC-ADAPTER-008 — Resolved Connector Remains Stable After Execution Plan Freeze

**Class:** FREEZE_STABILITY

**Condition**  
Execution plan frozen with an adapter-backed connector for Snowflake. Connector configuration remains unchanged.

**Description**  
Validate that the resolved connector implementation does not change after the execution plan is frozen.

**Acceptance Criteria**

- Frozen plan retains the resolved adapter-backed implementation
- Subsequent connector lookups for the frozen plan return the same implementation
- Connector resolution is not re-executed for the frozen plan

---

## Negative Functional Cases

### UAT-V021-FUNC-ADAPTER-009 — Unsupported Connector Is Rejected

**Class:** ADAPTER

**Condition**  
Connector `mongodb` is not enabled in the Supported Connector Registry. No adapter or native implementation is enabled for it.

**Description**  
Validate that an unsupported connector is rejected during resolution.

**Acceptance Criteria**

- Connector resolution fails
- Error message identifies `mongodb` as unsupported
- Error message references Supported Connector Registry
- Preflight validation does not proceed

---

### UAT-V021-FUNC-ADAPTER-010 — Disabled Adapter Is Ignored During Resolution

**Class:** ADAPTER

**Condition**  
All adapters supporting Snowflake are disabled in adapter registry. Snowflake has no native implementation.

**Description**  
Validate that a disabled adapter does not participate in connector resolution.

**Acceptance Criteria**

- Connector resolution does not return any adapter-backed implementation
- Resolution fails for Snowflake
- Error message confirms no available implementation
- Disabled adapters are not consulted

---

### UAT-V021-FUNC-ADAPTER-011 — Connector Not Enabled in Supported Connector Registry Is Rejected

**Class:** ADAPTER

**Condition**  
Snowflake is disabled in Supported Connector Registry. An enabled adapter supports Snowflake.

**Description**  
Validate that adapter support alone does not make a connector available. Supported Connector Registry enforcement takes precedence.

**Acceptance Criteria**

- Connector resolution fails for Snowflake
- Error message confirms connector is not in Supported Connector Registry
- Adapter capability is not sufficient to override registry

---

### UAT-V021-FUNC-ADAPTER-012 — Adapter Missing Required Capability Fails Preflight

**Class:** PREFLIGHT

**Condition**  
An adapter-backed connector does not support a capability required by the execution plan.

**Description**  
Validate that preflight validation fails when the adapter lacks required capabilities.

**Acceptance Criteria**

- Preflight validation fails
- Error message identifies the missing capability
- Error message identifies the adapter and connector
- Execution plan freeze is blocked

---

### UAT-V021-FUNC-ADAPTER-013 — Raw Adapter Exception Is Translated into Relix Runtime Error

**Class:** ERROR_SEMANTICS

**Condition**  
An adapter-backed connector encounters an internal adapter error during `write_batch()`. The adapter raises an adapter-specific exception.

**Description**  
Validate that raw adapter exceptions are caught and translated into Relix runtime errors.

**Acceptance Criteria**

- Error propagated to runtime is a Relix error type
- Error message does not contain raw adapter stack trace
- Error message is actionable for the operator
- Execution fails cleanly without adapter exception leakage

---

### UAT-V021-FUNC-ADAPTER-014 — Connector Resolution Fails If No Compatible Connector Exists

**Class:** ADAPTER

**Condition**  
Connector requested that has no native implementation and no enabled adapter supports it.

**Description**  
Validate clean failure when no compatible connector implementation exists.

**Acceptance Criteria**

- Connector resolution fails
- Error message identifies the connector
- Error message confirms no native or adapter implementation available
- Preflight validation does not proceed

---

### UAT-V021-FUNC-ADAPTER-015 — Runtime Does Not Switch Connector Implementation After Freeze

**Class:** FREEZE_STABILITY

**Condition**  
Execution plan frozen with an adapter-backed connector. A native implementation for the same connector is subsequently registered.

**Description**  
Validate that the runtime does not switch to a newly available implementation after the execution plan is frozen.

**Acceptance Criteria**

- Frozen execution plan continues to use the adapter-backed implementation
- Newly registered native implementation is not used for the frozen plan
- Recovery uses the original adapter-backed implementation
- Connector resolution stickiness is preserved

### UAT-V021-FUNC-ADAPTER-016 — Native and Adapter-Backed Implementations Both Exist

**Class:** ADAPTER

**Condition**  
Postgres has both a native implementation and an adapter-backed implementation. Selection policy is `native_preferred`.

**Description**  
Validate correct selection when both implementation types exist.

**Acceptance Criteria**

- Native `PostgresConnector` is selected
- Adapter-backed implementation is not selected
- Execution uses native connector
- If selection policy changes to `adapter_preferred`, adapter-backed implementation is selected

---

### UAT-V021-FUNC-ADAPTER-017 — Multiple Adapters Support Same Connector

**Class:** ADAPTER

**Condition**  
Two enabled adapters both support the same connector. No native implementation exists.

**Description**  
Validate that connector resolution selects one adapter deterministically.

**Acceptance Criteria**

- One adapter is selected consistently
- Selection is deterministic across repeated resolutions
- Selection follows the configured adapter resolution policy
- Both adapters are valid but only one is resolved
- Resolution is logged with the selected adapter identified

---

### UAT-V021-FUNC-ADAPTER-018 — Adapter Disabled After Execution Plan Freeze

**Class:** FREEZE_STABILITY

**Condition**  
Execution plan frozen with an adapter-backed connector. That adapter is subsequently disabled in adapter registry.

**Description**  
Validate that disabling an adapter does not invalidate frozen execution plans that already resolved it.

**Acceptance Criteria**

- Frozen execution plan continues to execute successfully
- Recovery succeeds after adapter disablement
- Disabled adapter is not available for new execution plans
- Existing plan completion is not affected

---

### UAT-V021-FUNC-ADAPTER-019 — Adapter Deregistered After Execution Plan Freeze

**Class:** FREEZE_STABILITY

**Condition**  
Execution plan frozen with an adapter-backed connector. That adapter is subsequently deregistered from adapter registry.

**Description**  
Validate that deregistration does not invalidate frozen execution plans.

**Acceptance Criteria**

- Frozen execution plan continues to execute successfully
- Recovery succeeds after adapter deregistration
- Deregistered adapter is not available for new execution plans or resolutions
- Existing plan uses its previously resolved implementation until completion

---

### UAT-V021-FUNC-ADAPTER-020 — Connector Capability Changes After Plan Freeze

**Class:** FREEZE_STABILITY

**Condition**  
Execution plan frozen. The resolved connector's capability declaration is subsequently updated to remove a previously supported capability.

**Description**  
Validate that capability changes after freeze do not affect the frozen plan.

**Acceptance Criteria**

- Frozen execution plan continues to execute
- Plan uses capabilities as resolved at freeze time
- Recovery succeeds despite capability declaration change
- New execution plans see the updated capabilities

---

### UAT-V021-FUNC-ADAPTER-021 — Adapter-Backed Connector Partially Supports Required Capabilities

**Class:** PREFLIGHT

**Condition**  
An adapter-backed connector supports read and write but does not support `create_table`. Execution plan requires `create_table`.

**Description**  
Validate that partial capability support causes preflight failure.

**Acceptance Criteria**

- Preflight validation fails
- Error message lists `create_table` as unsupported
- Error message identifies the connector and adapter
- Execution plan freeze is blocked

---

# UAT Area 2 — Standard Access Profile Framework

## Positive Functional Cases

### UAT-V021-FUNC-ACCESS-PROFILE-001 — Standard Profile read_only Is Registered

**Class:** ACCESS_PROFILE

**Condition**  
Access Profile Registry is initialized.

**Description**  
Validate that the `read_only` standard profile is registered with correct permissions.

**Acceptance Criteria**

- Profile `read_only` exists in registry
- Permissions are: `read`, `discover_schema`
- Profile is retrievable by name
- Profile is enabled by default

---

### UAT-V021-FUNC-ACCESS-PROFILE-002 — Standard Profile read_metadata Is Registered

**Class:** ACCESS_PROFILE

**Condition**  
Access Profile Registry is initialized.

**Description**  
Validate that the `read_metadata` standard profile is registered with correct permissions.

**Acceptance Criteria**

- Profile `read_metadata` exists in registry
- Permissions are: `read`, `discover_schema`, `get_statistics`
- Profile is retrievable by name
- Profile is enabled by default

---

### UAT-V021-FUNC-ACCESS-PROFILE-003 — Standard Profile read_write Is Registered

**Class:** ACCESS_PROFILE

**Condition**  
Access Profile Registry is initialized.

**Description**  
Validate that the `read_write` standard profile is registered with correct permissions.

**Acceptance Criteria**

- Profile `read_write` exists in registry
- Permissions are: `read`, `write`, `discover_schema`
- Profile is retrievable by name
- Profile is enabled by default

---

### UAT-V021-FUNC-ACCESS-PROFILE-004 — Standard Profile read_write_ddl Is Registered

**Class:** ACCESS_PROFILE

**Condition**  
Access Profile Registry is initialized.

**Description**  
Validate that the `read_write_ddl` standard profile is registered with correct permissions.

**Acceptance Criteria**

- Profile `read_write_ddl` exists in registry
- Permissions are:
  - `read`
  - `write`
  - `create_table`
  - `alter_table`
  - `drop_table`
  - `truncate`
  - `discover_schema`
- Profile is retrievable by name
- Profile is enabled by default

---

### UAT-V021-FUNC-ACCESS-PROFILE-005 — Standard Profile admin Is Registered

**Class:** ACCESS_PROFILE

**Condition**  
Access Profile Registry is initialized.

**Description**  
Validate that the `admin` standard profile is registered with wildcard permission.

**Acceptance Criteria**

- Profile `admin` exists in registry
- Permissions are: `*` (all v0.2.1 taxonomy permissions)
- Profile is retrievable by name
- Profile is enabled by default

---

### UAT-V021-FUNC-ACCESS-PROFILE-006 — Custom Profile Registration Succeeds

**Class:** ACCESS_PROFILE

**Condition**  
Administrator defines a custom profile with valid permissions from the v0.2.1 taxonomy.

**Description**  
Validate that a custom profile can be registered and used.

**Acceptance Criteria**

- Custom profile registration succeeds
- Profile appears in profile listing
- Profile is retrievable by name
- Profile permissions match the definition

---

### UAT-V021-FUNC-ACCESS-PROFILE-007 — Profile Retrieval Works

**Class:** ACCESS_PROFILE

**Condition**  
Profile `read_only` is registered.

**Description**  
Validate that a profile can be retrieved by name.

**Acceptance Criteria**

- Profile retrieval returns the correct profile definition
- Permissions list matches registered permissions
- Profile metadata is included (description, enabled status)

---

### UAT-V021-FUNC-ACCESS-PROFILE-008 — Profile Listing Works

**Class:** ACCESS_PROFILE

**Condition**  
Multiple profiles are registered.

**Description**  
Validate that all registered profiles can be listed.

**Acceptance Criteria**

- Profile listing returns all registered profiles
- Each profile includes its name and enabled status
- Standard profiles and custom profiles both appear

---

### UAT-V021-FUNC-ACCESS-PROFILE-009 — Profile Capability Compatibility Check Passes

**Class:** ACCESS_PROFILE

**Condition**  
Profile `read_write_ddl` is checked against `PostgresConnector` which supports all required capabilities.

**Description**  
Validate that capability mapping succeeds when connector supports all profile permissions.

**Acceptance Criteria**

- Capability compatibility check returns PASS
- All required permissions are confirmed as supported
- No errors or warnings generated

---

### UAT-V021-FUNC-ACCESS-PROFILE-010 — Profile Disablement Prevents Future Use

**Class:** ACCESS_PROFILE

**Condition**  
Profile `read_write` is enabled. Administrator disables it.

**Description**  
Validate that a disabled profile is not available for new bindings or execution plans.

**Acceptance Criteria**

- Profile disablement succeeds
- Disabled profile is not assignable to new bindings
- Disabled profile is not assignable to new execution plans
- Disabled profile is still listed in registry with disabled status

---

### UAT-V021-FUNC-ACCESS-PROFILE-011 — Disabled Profile Remains Valid for Frozen Execution Plans

**Class:** FREEZE_STABILITY

**Condition**  
Execution plan frozen with profile `read_write`. Profile is subsequently disabled.

**Description**  
Validate that disabling a profile does not affect existing frozen execution plans.

**Acceptance Criteria**

- Frozen execution plan continues to execute
- Plan uses `read_write` permissions as resolved at freeze time
- Recovery succeeds with the disabled profile
- Reconciliation succeeds with the disabled profile

---

### UAT-V021-FUNC-ACCESS-PROFILE-012 — Custom Profile Update Creates a New Version

**Class:** ACCESS_PROFILE

**Condition**  
Custom profile `custom_reader` is updated to add `get_statistics` permission.

**Description**  
Validate that updating a custom profile creates a new version rather than modifying the existing one.

**Acceptance Criteria**

- Update succeeds and creates version 2
- Version 1 remains unchanged
- Version 2 includes `get_statistics` permission
- Profile retrieval returns the current version (version 2)

---

### UAT-V021-FUNC-ACCESS-PROFILE-013 — Frozen Execution Plan Retains Resolved Custom Profile Version

**Class:** FREEZE_STABILITY

**Condition**  
Execution plan frozen with custom profile `custom_reader` version 1. Profile is subsequently updated to version 2.

**Description**  
Validate that a frozen execution plan retains the custom profile version resolved at freeze time.

**Acceptance Criteria**

- Frozen plan continues to use version 1
- Version 1 permissions are enforced during execution
- Recovery uses version 1
- New execution plans resolve to version 2

---

## Negative Functional Cases

### UAT-V021-FUNC-ACCESS-PROFILE-014 — Unknown Permission Is Rejected

**Class:** ACCESS_PROFILE

**Condition**  
Administrator attempts to register a profile with permission `manage_credentials`, which is not in the v0.2.1 taxonomy.

**Description**  
Validate that unknown permissions are rejected at registration time.

**Acceptance Criteria**

- Profile registration fails
- Error message identifies `manage_credentials` as unknown
- Error message references v0.2.1 permission taxonomy
- Profile is not added to registry

---

### UAT-V021-FUNC-ACCESS-PROFILE-015 — Duplicate Profile Name Is Rejected

**Class:** ACCESS_PROFILE

**Condition**  
Administrator attempts to register a profile with name `read_only`, which already exists.

**Description**  
Validate that duplicate profile names are rejected.

**Acceptance Criteria**

- Profile registration fails
- Error message identifies `read_only` as duplicate
- Original profile remains unchanged
- No new profile is created

---

### UAT-V021-FUNC-ACCESS-PROFILE-016 — Profile Requiring Unsupported Connector Capability Fails Preflight

**Class:** PREFLIGHT

**Condition**  
Profile `read_write_ddl` is checked against a limited-capability connector that does not support `create_table`, `alter_table`, `drop_table`, or `truncate`.

**Description**  
Validate that capability mapping fails when connector lacks required capabilities.

**Acceptance Criteria**

- Capability compatibility check returns FAIL
- Error message lists unsupported permissions
- Error message identifies the connector and profile
- Preflight validation is blocked

---

### UAT-V021-FUNC-ACCESS-PROFILE-017 — Profile Deletion Is Rejected When In Use

**Class:** ACCESS_PROFILE

**Condition**  
Profile `read_only` is referenced by a frozen execution plan. Administrator attempts to delete the profile.

**Description**  
Validate that profile deletion is blocked when any frozen execution plan references it.

**Acceptance Criteria**

- Profile deletion is rejected
- Error message confirms profile is referenced by frozen execution plan(s)
- Error message suggests disabling the profile as alternative
- Profile remains in registry

---

### UAT-V021-FUNC-ACCESS-PROFILE-018 — Profile Version Modification Is Rejected When Referenced

**Class:** ACCESS_PROFILE

**Condition**  
Profile `read_only` version 1 is referenced by a frozen execution plan. Administrator attempts to modify version 1.

**Description**  
Validate that immutable profile versions cannot be modified.

**Acceptance Criteria**

- Modification of version 1 is rejected
- Error message confirms version is referenced by frozen execution plan(s)
- Error message suggests creating a new version
- Version 1 remains unchanged

## Edge Functional Cases

### UAT-V021-FUNC-ACCESS-PROFILE-019 — Multiple Versions of Same Profile Coexist

**Class:** ACCESS_PROFILE

**Condition**  
Profile `read_only` has version 1 referenced by frozen plan A, version 2 referenced by frozen plan B.

**Description**  
Validate that multiple profile versions coexist and are correctly resolved per plan.

**Acceptance Criteria**

- Version 1 and version 2 both exist in registry
- Plan A uses version 1 permissions
- Plan B uses version 2 permissions
- Both plans execute successfully with their respective versions

---

### UAT-V021-FUNC-ACCESS-PROFILE-020 — Profile Disabled While Execution Is In Progress

**Class:** FREEZE_STABILITY

**Condition**  
Execution is in progress using profile `read_write`. Administrator disables the profile during execution.

**Description**  
Validate that disabling a profile during execution does not interrupt the in-progress execution.

**Acceptance Criteria**

- Profile disablement succeeds
- In-progress execution continues without interruption
- Execution completes successfully
- Profile is disabled for future use after execution completes

---

### UAT-V021-FUNC-ACCESS-PROFILE-021 — Profile Deleted When No Frozen Plan References It

**Class:** ACCESS_PROFILE

**Condition**  
Custom profile exists with no references from any frozen execution plan or active binding.

**Description**  
Validate that a profile with no references can be deleted.

**Acceptance Criteria**

- Profile deletion succeeds
- Profile is removed from registry
- Profile no longer appears in listing
- Profile retrieval returns not found

---

### UAT-V021-FUNC-ACCESS-PROFILE-022 — Admin Profile Expands to All v0.2.1 Taxonomy Permissions

**Class:** ACCESS_PROFILE

**Condition**  
Admin profile uses wildcard `*` permission. Connector supports all v0.2.1 taxonomy permissions.

**Description**  
Validate that the wildcard expands to all permissions in the current taxonomy.

**Acceptance Criteria**

- Capability check passes for all v0.2.1 permissions
- Admin profile grants every permission in the taxonomy
- No individual permission is excluded

---

### UAT-V021-FUNC-ACCESS-PROFILE-023 — Custom Profile Uses Only Subset of Permissions

**Class:** ACCESS_PROFILE

**Condition**  
Custom profile is registered with only `read` and `discover_schema` permissions.

**Description**  
Validate that a custom profile with a permission subset functions correctly.

**Acceptance Criteria**

- Profile registration succeeds
- Capability check verifies only `read` and `discover_schema`
- Profile does not grant `write` or other permissions
- Runtime enforcement respects the subset

---

### UAT-V021-FUNC-ACCESS-PROFILE-024 — Future/Deferred Permission Is Rejected in v0.2.1

**Class:** ACCESS_PROFILE

**Condition**  
Administrator attempts to register a profile with `read_change_log`, which is deferred beyond v0.2.1.

**Description**  
Validate that deferred permissions are rejected.

**Acceptance Criteria**

- Profile registration fails
- Error message identifies `read_change_log` as not in v0.2.1 taxonomy
- Error message does not imply the permission will never exist
- Profile is not registered

---

# UAT Area 3 — Connector Access Profile Binding

## Positive Functional Cases

### UAT-V021-FUNC-BINDING-001 — Binding Registration Works

**Class:** BINDING

**Condition**  
Administrator registers a binding associating `PostgresConnector` with `read_only` profile.

**Description**  
Validate that a connector-to-profile binding can be created.

**Acceptance Criteria**

- Binding registration succeeds
- Binding name is assigned
- Binding references correct connector and profile
- Binding is enabled by default

---

### UAT-V021-FUNC-BINDING-002 — Binding Retrieval Works

**Class:** BINDING

**Condition**  
Binding exists in registry.

**Description**  
Validate that a binding can be retrieved by name.

**Acceptance Criteria**

- Binding retrieval returns the correct binding definition
- Connector reference is correct
- Profile reference is correct
- Binding metadata is included (enabled status, version)

---

### UAT-V021-FUNC-BINDING-003 — Binding Listing Works

**Class:** BINDING

**Condition**  
Multiple bindings are registered.

**Description**  
Validate that all bindings can be listed.

**Acceptance Criteria**

- Binding listing returns all registered bindings
- Each binding includes connector reference, profile reference, and enabled status
- Bindings are identifiable by name

---

### UAT-V021-FUNC-BINDING-004 — Binding Connects Connector Instance to Access Profile

**Class:** BINDING

**Condition**  
Binding registered. Execution plan references the binding.

**Description**  
Validate that the binding correctly associates the connector with the profile at runtime.

**Acceptance Criteria**

- Resolved binding provides the correct connector implementation
- Resolved binding provides the correct profile permissions
- Runtime uses the profile permissions for enforcement
- Connector and profile are correctly linked

---

### UAT-V021-FUNC-BINDING-005 — Multiple Bindings for Same Connector Are Supported

**Class:** BINDING

**Condition**  
`PostgresConnector` has two bindings: one with `read_only`, one with `admin`.

**Description**  
Validate that a single connector can have multiple independent bindings.

**Acceptance Criteria**

- Both bindings are registered successfully
- Each binding references the correct profile independently
- Binding lifecycle operations on one do not affect the other
- Each binding is retrievable separately

---

### UAT-V021-FUNC-BINDING-006 — Binding Preflight Compatibility Check Passes

**Class:** PREFLIGHT

**Condition**  
Binding associates `PostgresConnector` with `read_only` profile. Connector supports `read` and `discover_schema`.

**Description**  
Validate that preflight passes when binding is fully compatible.

**Acceptance Criteria**

- Preflight compatibility check returns PASS
- Connector capability check against profile permissions passes
- Execution plan freeze is allowed

---

### UAT-V021-FUNC-BINDING-007 — Binding Enablement Works

**Class:** BINDING

**Condition**  
Binding is disabled. Administrator enables it.

**Description**  
Validate that enabling a binding makes it available for new execution plans.

**Acceptance Criteria**

- Binding enablement succeeds
- Binding status changes to enabled
- Enabled binding is available for new execution plans
- Existing frozen plans are unaffected

---

### UAT-V021-FUNC-BINDING-008 — Binding Disablement Works

**Class:** BINDING

**Condition**  
Binding is enabled. Administrator disables it.

**Description**  
Validate that disabling a binding prevents future use without affecting frozen plans.

**Acceptance Criteria**

- Binding disablement succeeds
- Binding status changes to disabled
- Disabled binding is not available for new execution plans
- Existing frozen plans continue to function

---

### UAT-V021-FUNC-BINDING-009 — Binding Update Creates New Binding Version

**Class:** BINDING

**Condition**  
Binding exists at version 1. Administrator updates it to reference a different profile.

**Description**  
Validate that updating a binding creates a new version.

**Acceptance Criteria**

- Update succeeds and creates version 2
- Version 1 remains unchanged
- Version 2 references the new profile
- Binding retrieval returns the current version (version 2)

---

### UAT-V021-FUNC-BINDING-010 — Frozen Execution Plan Retains Resolved Binding Version

**Class:** FREEZE_STABILITY

**Condition**  
Execution plan frozen with binding version 1. Binding is updated to version 2.

**Description**  
Validate that a frozen execution plan retains the binding version resolved at freeze time.

**Acceptance Criteria**

- Frozen plan continues to use version 1
- Version 1 connector and profile are used during execution
- Recovery uses version 1
- New execution plans resolve to version 2

---

### UAT-V021-FUNC-BINDING-011 — Runtime Allows Operation Permitted by Bound Profile

**Class:** RUNTIME_ENFORCEMENT

**Condition**  
Connector bound to `read_write` profile. Execution plan frozen.

**Description**  
Validate that operations granted by the bound profile execute successfully.

**Acceptance Criteria**

- `read_batch()` succeeds (permitted by `read`)
- `write_batch()` succeeds (permitted by `write`)
- `discover_schema()` succeeds (permitted by `discover_schema`)
- No permission errors generated

---

## Negative Functional Cases

### UAT-V021-FUNC-BINDING-012 — Binding to Unknown Connector Is Rejected

**Class:** BINDING

**Condition**  
Administrator attempts to create a binding referencing a connector that does not exist in the connector registry.

**Description**  
Validate that bindings to unknown connectors are rejected.

**Acceptance Criteria**

- Binding registration fails
- Error message identifies the unknown connector
- Error message suggests verifying connector name
- Binding is not created

---

### UAT-V021-FUNC-BINDING-013 — Binding to Unknown Profile Is Rejected

**Class:** BINDING

**Condition**  
Administrator attempts to create a binding referencing a profile that does not exist in the access profile registry.

**Description**  
Validate that bindings to unknown profiles are rejected.

**Acceptance Criteria**

- Binding registration fails
- Error message identifies the unknown profile
- Error message suggests verifying profile name
- Binding is not created

---

### UAT-V021-FUNC-BINDING-014 — Binding to Disabled Profile Is Rejected for New Plans

**Class:** BINDING

**Condition**  
Profile is disabled at the profile registry level. Administrator attempts to create a new binding using the disabled profile.

**Description**  
Validate that disabled profiles cannot be used in new bindings. The profile registry-level disabled status is enforced at the binding registry level.

**Acceptance Criteria**

- Binding registration fails
- Error message identifies the profile as disabled
- Error message references the profile registry status
- Binding is not created

---

### UAT-V021-FUNC-BINDING-015 — Binding Requiring Unsupported Connector Capability Fails Preflight

**Class:** PREFLIGHT

**Condition**  
Binding associates a limited-capability connector with `read_write_ddl` profile. The connector does not support DDL capabilities.

**Description**  
Validate that preflight fails when the binding requires capabilities the connector does not support.

**Acceptance Criteria**

- Preflight validation fails
- Error message lists unsupported permissions
- Error message identifies the connector and profile
- Execution plan freeze is blocked

---

### UAT-V021-FUNC-BINDING-016 — Runtime Rejects Operation Not Permitted by Bound Profile

**Class:** RUNTIME_ENFORCEMENT

**Condition**  
Connector bound to `read_only` profile. Execution plan attempts `write_batch()`.

**Description**  
Validate that runtime enforcement rejects operations not granted by the bound profile.

**Acceptance Criteria**

- `write_batch()` is rejected before reaching the connector
- Error message identifies the operation and the missing permission
- Error message identifies the binding and profile
- Connector is never invoked for the rejected operation

### UAT-V021-FUNC-BINDING-017 — Binding Deletion Is Rejected When Any Version Is In Use

**Class:** BINDING

**Condition**  
Binding has version 1 referenced by a frozen execution plan. Administrator attempts to delete the binding.

**Description**  
Validate that binding deletion is blocked when any version is referenced.

**Acceptance Criteria**

- Binding deletion is rejected
- Error message confirms a version is referenced by frozen execution plan(s)
- Error message suggests disabling the binding as alternative
- Binding remains in registry

---

### UAT-V021-FUNC-BINDING-018 — Binding Version Deletion Is Rejected When Referenced

**Class:** BINDING

**Condition**  
Binding version 1 is referenced by a frozen execution plan. Administrator attempts to delete version 1.

**Description**  
Validate that individual binding version deletion is blocked when referenced.

**Acceptance Criteria**

- Version deletion is rejected
- Error message confirms version is referenced by frozen execution plan(s)
- Error message suggests creating a new version
- Version 1 remains in registry

---

### UAT-V021-FUNC-BINDING-019 — Binding Modification Is Rejected When Referenced by Frozen Plan

**Class:** BINDING

**Condition**  
Binding version 1 is referenced by a frozen execution plan. Administrator attempts to modify version 1.

**Description**  
Validate that binding version modification is blocked when referenced.

**Acceptance Criteria**

- Modification of version 1 is rejected
- Error message confirms version is referenced by frozen execution plan(s)
- Error message suggests creating a new version
- Version 1 remains unchanged

---

## Edge Functional Cases

### UAT-V021-FUNC-BINDING-020 — Binding Disabled After Execution Plan Freeze

**Class:** FREEZE_STABILITY

**Condition**  
Execution plan frozen with binding at version 1. Binding is subsequently disabled.

**Description**  
Validate that disabling a binding does not affect frozen execution plans.

**Acceptance Criteria**

- Binding disablement succeeds
- Frozen execution plan continues to execute
- Recovery succeeds with the disabled binding
- Binding is not available for new execution plans

---

### UAT-V021-FUNC-BINDING-021 — Profile Disabled After Binding Is Frozen into Execution Plan

**Class:** FREEZE_STABILITY

**Condition**  
Execution plan frozen with binding referencing profile `read_write`. Profile `read_write` is subsequently disabled.

**Description**  
Validate that disabling a profile does not affect frozen execution plans that reference it through a binding.

**Acceptance Criteria**

- Profile disablement succeeds
- Frozen execution plan continues to execute
- Binding continues to function for the frozen plan
- Profile is not available for new bindings

---

### UAT-V021-FUNC-BINDING-022 — Multiple Bindings Use Same Connector with Different Profiles

**Class:** BINDING

**Condition**  
`PostgresConnector` has `binding_A` with `read_only` and `binding_B` with `admin`.

**Description**  
Validate that different bindings for the same connector enforce different permissions independently.

**Acceptance Criteria**

- Execution plan using `binding_A` is restricted to `read_only` permissions
- Execution plan using `binding_B` has `admin` permissions
- `binding_A` enforcement does not affect `binding_B`
- Each binding resolves independently

---

### UAT-V021-FUNC-BINDING-023 — Connector Capability Changes After Binding Resolution

**Class:** FREEZE_STABILITY

**Condition**  
Execution plan frozen with binding. Connector capability declaration is subsequently updated to remove a previously supported capability.

**Description**  
Validate that capability changes after freeze do not affect the frozen binding.

**Acceptance Criteria**

- Frozen execution plan continues to execute
- Plan uses capabilities as resolved at freeze time
- Recovery succeeds despite capability change
- New execution plans see the updated capabilities

---

### UAT-V021-FUNC-BINDING-024 — Runtime Recovery Uses Frozen Binding Version

**Class:** FREEZE_STABILITY

**Condition**  
Execution plan frozen with binding version 1. Binding is updated to version 2. Checkpoint recovery is triggered.

**Description**  
Validate that recovery uses the binding version from the frozen execution plan.

**Acceptance Criteria**

- Recovery resolves to binding version 1
- Version 1 permissions are enforced during recovery
- Binding version 2 is not used for recovery
- Recovery completes successfully

---

### UAT-V021-FUNC-BINDING-025 — Replay Validation Uses Frozen Binding Version

**Class:** FREEZE_STABILITY

**Condition**  
Execution plan frozen with binding version 1. Binding is updated to version 2. Replay validation is triggered.

**Description**  
Validate that replay validation uses the binding version from the frozen execution plan.

**Acceptance Criteria**

- Replay validation resolves to binding version 1
- Version 1 permissions are enforced during replay
- Binding version 2 is not used for replay
- Replay validation results are consistent with original execution

---

### UAT-V021-FUNC-BINDING-026 — Binding Version Deletion Succeeds When Unreferenced

**Class:** BINDING

**Condition**  
Binding version exists and is not referenced by any frozen execution plan.

**Description**  
Validate that an unreferenced binding version can be deleted.

**Acceptance Criteria**

- Binding version deletion succeeds
- Deleted version is removed from registry
- Other binding versions remain available
- No frozen execution plan references the deleted version

---

# UAT Area 4 — Transport Encryption Validation

## Positive Functional Cases

### UAT-V021-FUNC-TRANSPORT-001 — Transport Security Configuration Is Accepted

**Class:** TRANSPORT

**Condition**  
Administrator configures transport security with `sslmode: require` and `verify_certificate: true` for a connector.

**Description**  
Validate that valid transport security configuration is accepted.

**Acceptance Criteria**

- Configuration is accepted and stored
- Configuration is associated with the correct connector
- Configuration is retrievable

---

### UAT-V021-FUNC-TRANSPORT-002 — Connector Exposes Transport Capabilities

**Class:** TRANSPORT

**Condition**  
`PostgresConnector` is registered.

**Description**  
Validate that connectors expose transport security capabilities through metadata.

**Acceptance Criteria**

- `PostgresConnector` exposes `transport_encryption` capability
- `PostgresConnector` exposes `certificate_validation` capability
- Capabilities are accessible through connector metadata interface

---

### UAT-V021-FUNC-TRANSPORT-003 — PostgreSQL Supports Mode disable

**Class:** TRANSPORT

**Condition**  
`PostgresConnector` configured with `sslmode: disable`.

**Description**  
Validate that PostgreSQL connectors support the disable transport mode.

**Acceptance Criteria**

- Configuration is accepted
- Preflight validation passes
- Connection is established without encryption
- Effective transport state reports encryption as disabled

---

### UAT-V021-FUNC-TRANSPORT-004 — PostgreSQL Supports Mode allow

**Class:** TRANSPORT

**Condition**  
`PostgresConnector` configured with `sslmode: allow`.

**Description**  
Validate that PostgreSQL connectors support the allow transport mode.

**Acceptance Criteria**

- Configuration is accepted
- Preflight validation passes
- Connection is established (encryption optional)
- Effective transport state is reported

---

### UAT-V021-FUNC-TRANSPORT-005 — PostgreSQL Supports Mode prefer

**Class:** TRANSPORT

**Condition**  
`PostgresConnector` configured with `sslmode: prefer`. Server supports TLS.

**Description**  
Validate that PostgreSQL connectors attempt encryption in prefer mode when available.

**Acceptance Criteria**

- Configuration is accepted
- Preflight validation passes
- Connection is established with encryption
- Effective transport state reports encryption as active

---

### UAT-V021-FUNC-TRANSPORT-006 — PostgreSQL Supports Mode require

**Class:** TRANSPORT

**Condition**  
`PostgresConnector` configured with `sslmode: require`. Server supports TLS.

**Description**  
Validate that PostgreSQL connectors enforce encryption in require mode.

**Acceptance Criteria**

- Configuration is accepted
- Preflight validation passes
- Connection is established with encryption
- Connection is blocked if server does not support TLS

---

### UAT-V021-FUNC-TRANSPORT-007 — PostgreSQL Supports Mode verify-ca

**Class:** TRANSPORT

**Condition**  
`PostgresConnector` configured with `sslmode: verify-ca`. Valid CA certificate available.

**Description**  
Validate that PostgreSQL connectors support CA validation.

**Acceptance Criteria**

- Configuration is accepted
- Preflight validation passes
- Connection is established with encryption and CA validation
- Connection is blocked if CA does not match

---

### UAT-V021-FUNC-TRANSPORT-008 — PostgreSQL Supports Mode verify-full

**Class:** TRANSPORT

**Condition**  
`PostgresConnector` configured with `sslmode: verify-full`. Valid CA and hostname certificate available.

**Description**  
Validate that PostgreSQL connectors support full certificate validation.

**Acceptance Criteria**

- Configuration is accepted
- Preflight validation passes
- Connection is established with encryption and full certificate validation
- Connection is blocked if hostname does not match certificate

---

### UAT-V021-FUNC-TRANSPORT-009 — Preflight Passes When Required Encryption Is Available

**Class:** PREFLIGHT

**Condition**  
Connector configured with `sslmode: require`. Connector supports `transport_encryption`. Server supports TLS.

**Description**  
Validate that preflight passes when transport requirements are met.

**Acceptance Criteria**

- Preflight transport validation passes
- Capability check confirms `transport_encryption` is supported
- Mode support check confirms `require` is available
- Execution plan freeze is allowed

---

### UAT-V021-FUNC-TRANSPORT-010 — Preflight Passes When Transport Is Optional and Unavailable

**Class:** PREFLIGHT

**Condition**  
Connector configured with `sslmode: allow`. Server does not support TLS.

**Description**  
Validate that preflight passes when encryption is optional even if unavailable.

**Acceptance Criteria**

- Preflight transport validation passes
- Connection falls back to unencrypted
- No error is generated
- Execution proceeds

---

### UAT-V021-FUNC-TRANSPORT-011 — Certificate Validation Passes When Configured and Supported

**Class:** TRANSPORT

**Condition**  
Connector configured with `sslmode: verify-full`. Connector supports `certificate_validation`. Valid certificate available.

**Description**  
Validate that certificate validation succeeds when properly configured.

**Acceptance Criteria**

- Certificate validation check passes during preflight
- Connection is established with validated certificate
- Effective transport state includes certificate validation

---

### UAT-V021-FUNC-TRANSPORT-012 — Runtime Uses Validated Transport Configuration

**Class:** RUNTIME_ENFORCEMENT

**Condition**  
Transport configuration validated during preflight. Execution proceeds.

**Description**  
Validate that runtime uses the transport configuration validated during preflight.

**Acceptance Criteria**

- Connection uses the configured `sslmode`
- Certificate validation matches configuration
- Runtime does not downgrade transport security
- Effective transport state matches configuration

---

### UAT-V021-FUNC-TRANSPORT-013 — Transport Validation Events Are Emitted

**Class:** TRANSPORT

**Condition**  
Transport validation is performed.

**Description**  
Validate that transport validation events are emitted into the event stream.

**Acceptance Criteria**

- `TRANSPORT_VALIDATION_STARTED` event is emitted
- `TRANSPORT_VALIDATION_PASSED` event is emitted on success
- Events include connector identifier
- Events include transport mode

## Negative Functional Cases

### UAT-V021-FUNC-TRANSPORT-014 — Encryption Required but Connector Lacks transport_encryption Capability

**Class:** TRANSPORT

**Condition**  
Connector configured with `sslmode: require`. Connector does not expose `transport_encryption` capability.

**Description**  
Validate that preflight fails when encryption is required but the connector does not support it.

**Acceptance Criteria**

- Preflight transport validation fails
- Error message identifies missing `transport_encryption` capability
- Error message identifies the connector
- Execution plan freeze is blocked

---

### UAT-V021-FUNC-TRANSPORT-015 — Encryption Required but Configured Mode Is disable

**Class:** TRANSPORT

**Condition**  
Connector configured with `sslmode: disable`. Connector supports `transport_encryption`. Execution plan requires encrypted transport.

**Description**  
Validate that preflight fails when required encryption conflicts with disabled transport mode.

**Acceptance Criteria**

- Preflight transport validation fails
- Error message identifies conflict between requirement and disable mode
- Error message identifies the connector
- Execution plan freeze is blocked

---

### UAT-V021-FUNC-TRANSPORT-016 — Certificate Validation Required but Connector Lacks certificate_validation Capability

**Class:** TRANSPORT

**Condition**  
Connector configured with `sslmode: verify-full`. Connector does not expose `certificate_validation` capability.

**Description**  
Validate that preflight fails when certificate validation is required but not supported.

**Acceptance Criteria**

- Preflight transport validation fails
- Error message identifies missing `certificate_validation` capability
- Error message identifies the connector
- Execution plan freeze is blocked

---

### UAT-V021-FUNC-TRANSPORT-017 — Unsupported Transport Mode Fails Preflight

**Class:** PREFLIGHT

**Condition**  
Connector configured with `sslmode: verify-full`. Connector only supports `disable`, `allow`, and `require` modes.

**Description**  
Validate that an unsupported transport mode causes preflight failure.

**Acceptance Criteria**

- Preflight transport validation fails
- Error message identifies `verify-full` as unsupported
- Error message lists supported modes for the connector
- Execution plan freeze is blocked

---

### UAT-V021-FUNC-TRANSPORT-018 — Malformed Transport Configuration Fails Preflight

**Class:** PREFLIGHT

**Condition**  
Connector transport security configuration contains an invalid `sslmode` value.

**Description**  
Validate that malformed configuration is caught during preflight.

**Acceptance Criteria**

- Preflight transport validation fails
- Error message identifies the invalid configuration
- Error message lists valid transport modes
- Execution plan freeze is blocked

---

### UAT-V021-FUNC-TRANSPORT-019 — Raw TLS Exception Is Not Exposed Directly

**Class:** ERROR_SEMANTICS

**Condition**  
Connector encounters a TLS handshake failure due to certificate mismatch.

**Description**  
Validate that raw TLS exceptions are translated into Relix runtime errors.

**Acceptance Criteria**

- Error propagated is a Relix runtime error type
- Error message describes the transport failure in actionable terms
- Error message does not contain raw TLS stack trace
- Raw driver exception is not exposed beyond connector boundary

---

### UAT-V021-FUNC-TRANSPORT-020 — Execution Is Blocked When Transport Validation Fails

**Class:** RUNTIME_ENFORCEMENT

**Condition**  
Transport validation fails during preflight for any blocking condition.

**Description**  
Validate that execution is blocked when transport requirements are not satisfied.

**Acceptance Criteria**

- Execution does not start
- Blocking reason is logged
- Error message identifies the transport validation failure
- Connector connection is never attempted

---

## Edge Functional Cases

### UAT-V021-FUNC-TRANSPORT-021 — Transport Mode prefer Falls Back When Encryption Is Optional

**Class:** TRANSPORT

**Condition**  
Connector configured with `sslmode: prefer`. Non-TLS endpoint does not support TLS.

**Description**  
Validate that prefer mode gracefully falls back to unencrypted when encryption is unavailable.

**Acceptance Criteria**

- Connection is established without encryption
- No error is generated
- Effective transport state reports encryption as unavailable
- Execution proceeds normally

---

### UAT-V021-FUNC-TRANSPORT-022 — Certificate Expires After Preflight

**Class:** TRANSPORT

**Condition**  
Certificate is valid during preflight. Certificate expires before runtime execution.

**Description**  
Validate that runtime detects expired certificates and fails with an explicit transport error.

**Acceptance Criteria**

- Runtime connection attempt fails
- Error message indicates certificate expiry
- Error is a Relix runtime error, not raw TLS exception
- Execution fails without corrupting checkpoint state

---

### UAT-V021-FUNC-TRANSPORT-023 — Runtime Transport Downgrade Is Detected

**Class:** RUNTIME_ENFORCEMENT

**Condition**  
Connector configured with `sslmode: require`. During runtime, connection is established but encryption is not active due to an unexpected downgrade.

**Description**  
Validate that runtime detects transport downgrade and fails execution.

**Acceptance Criteria**

- Runtime detects encryption is not active
- Error message indicates transport downgrade detected
- Execution fails with explicit transport error
- Connector is disconnected

---

### UAT-V021-FUNC-TRANSPORT-024 — Adapter-Backed Connector Exposes Transport Config Through Relix Governance

**Class:** TRANSPORT

**Condition**  
An adapter-backed Snowflake connector is configured with transport security settings.

**Description**  
Validate that adapter-backed connectors expose transport configuration through Relix governance, not through adapter-specific mechanisms.

**Acceptance Criteria**

- Transport configuration is managed through Relix configuration layer
- Adapter does not independently decide transport security policy
- Transport capabilities are declared through standard connector metadata
- Transport enforcement is Relix-controlled

---

### UAT-V021-FUNC-TRANSPORT-025 — Native and Adapter-Backed Connectors Expose Transport Capabilities Consistently

**Class:** TRANSPORT

**Condition**  
Postgres native connector and an adapter-backed connector both support transport encryption.

**Description**  
Validate that transport capabilities are exposed consistently across native and adapter-backed connectors.

**Acceptance Criteria**

- Both connector types use the same capability metadata interface
- `transport_encryption` capability declaration format is identical
- `certificate_validation` capability declaration format is identical
- Transport validation logic applies uniformly to both

---

### UAT-V021-FUNC-TRANSPORT-026 — Transport Failure During Recovery Does Not Corrupt Checkpoint State

**Class:** FREEZE_STABILITY

**Condition**  
Transport was valid during original execution. During checkpoint recovery, transport fails due to certificate change.

**Description**  
Validate that transport failure during recovery does not corrupt checkpoint state.

**Acceptance Criteria**

- Recovery attempt fails with transport error
- Checkpoint data remains intact
- Checkpoint is not modified by the failed recovery attempt
- Original checkpoint can be recovered once transport issue is resolved

---

### UAT-V021-FUNC-TRANSPORT-027 — Transport Failure During Reconciliation Does Not Corrupt Reconciliation Metadata

**Class:** FREEZE_STABILITY

**Condition**  
Transport was valid during original execution. During reconciliation, transport fails.

**Description**  
Validate that transport failure during reconciliation does not corrupt reconciliation metadata.

**Acceptance Criteria**

- Reconciliation attempt fails with transport error
- Reconciliation metadata remains intact
- Reconciliation metadata is not modified by the failed attempt
- Reconciliation can be retried once transport issue is resolved

---

# UAT Execution Rules

- Each UAT case must validate functional behavior only
- Each failure must produce explicit actionable error output
- Each preflight failure must block execution plan freeze
- Each frozen execution plan must retain resolved connector, profile, binding, and transport validation state
- No test should require solution-specific semantics such as migration, replication, CDC, DR, source, or target
- No test should require UI unless UI-based management is introduced separately
- Adapter-backed connector test cases MUST use adapter-neutral wording
- The same adapter-backed test case MUST be executable against multiple adapter implementations through the test execution matrix


