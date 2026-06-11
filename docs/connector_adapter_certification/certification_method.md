Adapter Certification Method
Purpose
Adapter Certification is separate from RXTA  (Relix tool for automated testing, another repo ) UAT.
RXTA UAT validates:
* FR behavior
* framework behavior
* runtime behavior
* release readiness
Adapter Certification validates:
* adapter correctness
* connector correctness
* CRUD behavior
* onboarding readiness
Certification provides confidence that an adapter-backed connector can safely participate in Relix execution.
 
⸻
 
Architecture Principle
Certification MUST execute through the same code path used by production Relix.
Certification MUST NOT directly access databases using adapter SDKs or database drivers.
Required execution path:
Certification Runner
        │
        ▼
Relix Public API
        │
        ▼
Connector Resolution
        │
        ▼
Resolved Adapter
        │
        ▼
Adapter SDK
        │
        ▼
Database
The following architecture is explicitly prohibited:
Certification Runner
        │
        ▼
Direct DB Driver
        │
        ▼
Database
Direct database access only proves driver functionality.
Certification must prove that the Relix adapter implementation functions correctly within the Relix connector framework.
 
⸻
 
Directory Structure
certification/
│
├── adapters/
│   ├── airbyte_certify.py
│   ├── singer_meltano_certify.py
│
├── reports/
│   └── adapter_certification_report.json
│
└── core/
    └── connector_certification_suite.py
 
⸻
 
Certification Execution Model
Each certification script shall:
1. Start Relix runtime components required for connector resolution.
2. Register the adapter.
3. Enable the adapter.
4. Register a certification connector.
5. Resolve the connector through Relix.
6. Execute certification checks through the resolved connector implementation.
7. Generate a certification report.
Certification MUST use:
* Relix Public API
* Relix connector resolution
* Relix capability mapping
* Relix connector abstraction
Certification MUST NOT bypass Relix.
 
⸻
 
Certification Validation Areas
Area	Validation
Registration	Adapter registers successfully in Relix
Discovery	Supported connectors are discoverable
Resolution	Relix resolves connector to adapter
Capability Mapping	Adapter exposes Relix-normalized capabilities
Connectivity	connect / validate_connectivity / disconnect
Schema Discovery	discover_schema returns expected metadata
CRUD Operations	create, write, read, update, delete (or supported subset)
Unsupported Operations	unsupported operations fail cleanly
Error Translation	adapter errors become Relix runtime errors
Report Generation	PASS / FAIL / PARTIAL status produced
 
⸻
 
Connector Interface Coverage
Certification should exercise the FR-034 connector interface whenever applicable.
connect()
disconnect()

validate_connectivity()

begin_batch()
commit_batch()
rollback_batch()

read_batch()
write_batch()

discover_schema()

get_capabilities()
The certification suite should be reusable across all adapter implementations.
 
⸻
 
Certification Scope Control
Certification SHALL remain intentionally small.
The objective is adapter onboarding confidence, not exhaustive database certification.
Do NOT execute:
every adapter
× every connector
× every database
× every operation
This creates unnecessary execution complexity.
 
⸻
 
Recommended Coverage
AirbyteConnectorAdapter
Use one representative supported connector.
Example:
AirbyteConnectorAdapter
    ↓
PostgreSQL
or
AirbyteConnectorAdapter
    ↓
MySQL
 
⸻
 
SingerMeltanoConnectorAdapter
Use one representative supported connector.
Example:
SingerMeltanoConnectorAdapter
    ↓
PostgreSQL
or
SingerMeltanoConnectorAdapter
    ↓
MySQL
 
⸻
 
Additional Databases
Additional certification connectors MAY be added when:
* connector risk is high
* connector behavior is significantly different
* a customer onboarding requires validation
Additional certification is optional.
 
⸻
 
Certification Report
Each certification run produces a report.
Example:
{
  "adapter": "AirbyteConnectorAdapter",
  "connector": "postgres",
  "status": "PASS",
  "checks": {
    "registration": "PASS",
    "discovery": "PASS",
    "resolution": "PASS",
    "capability_mapping": "PASS",
    "connectivity": "PASS",
    "schema_discovery": "PASS",
    "crud": "PASS",
    "error_translation": "PASS"
  }
}
 
⸻
 
Certification Outcomes
Status	Meaning
PASS	Adapter certified
PARTIAL	Adapter usable with documented limitations
FAIL	Adapter not certified
 
⸻
 
Registry Integration
Only certified connectors should be enabled in the Supported Connector Registry.
Certification failure may result in:
* connector disablement
* connector removal from Supported Connector Registry
* adapter disablement
* adapter deregistration
Certification failure MUST NOT invalidate frozen execution plans.
 
⸻
 
Relationship to RXTA UAT
RXTA UAT v0.2.2
Validates:
* registration
* discovery
* resolution
* policy behavior
* capability-aware resolution
* freeze stability
* runtime participation
Adapter Certification
Validates:
* connectivity
* schema discovery
* CRUD correctness
* capability declarations
* error translation
 
⸻
 
Final Rule
Adapter Certification SHALL be completed before onboarding a connector into the Supported Connector Registry.
RXTA UAT SHALL validate framework participation only.
Adapter Certification SHALL validate real connector behavior through the Relix API using the same adapter implementation and connector resolution path used in production.
This approach provides onboarding confidence without inflating FR-038 UAT execution IDs or creating an adapter × connector × database execution matrix explosion.

