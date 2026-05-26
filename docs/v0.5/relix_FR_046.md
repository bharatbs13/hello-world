FR-046 — Multi-Tenant Workspace UI & Administration

Target Version

v0.5 Enterprise Collaboration Layer

⸻

Scope

Platform / UI / Administration

⸻

Objective

Provide UI and CLI interfaces for tenant, workspace, user, and visibility administration.

The UI must expose tenant-aware operational capabilities while preserving runtime isolation.

⸻

Architecture

Administrator
↓
Tenant Administration UI / CLI
↓
Access Validator
↓
Tenant Isolation Framework
↓
Runtime Services

⸻

UI Capabilities

Tenant Management

Users can:

* create tenants
* edit tenants
* disable tenants
* view tenant information

⸻

Workspace Management

Users can:

* create workspaces
* edit workspaces
* archive workspaces
* assign users

⸻

Role Management

Users can:

* create roles
* assign permissions
* assign workspace visibility
* configure role mappings

⸻

Visibility Management

Users can configure:

* tenant visibility
* workspace visibility
* workflow visibility
* report visibility
* alert visibility

⸻

Tenant Context Switching

UI should display:

* active tenant
* active workspace

Users with access to multiple tenants/workspaces may switch context only through authorized selection.

All UI views must be filtered using:

* active tenant context
* active workspace context

Examples:

Current Context:

Tenant: Customer_A

Workspace: Production

Visible:

* workflows
* reports
* alerts
* dashboards
* connectors

Outside active context:

Not visible

⸻

Audit Visibility

Display:

* tenant activity history
* workspace activity history
* permission changes
* cross-tenant access history

⸻

Validation Rules

Configurations must validate:

* role permissions
* workspace ownership
* tenant ownership
* visibility constraints
* isolation policy rules

⸻

CLI Examples

relix tenant create

relix tenant list

relix workspace create

relix workspace users

relix tenant permissions

relix workspace switch

⸻

Acceptance Criteria

1. Tenant administration is supported.
2. Workspace administration is supported.
3. Role assignment is supported.
4. Visibility rules are enforced.
5. Active tenant/workspace context is visible.
6. Context switching is authorization controlled.
7. Audit history is visible.
8. Cross-tenant access history is visible.
9. CLI and UI remain behaviorally consistent.

⸻

Non-Goals

Not included:

* tenant-aware optimization
* autonomous permission generation
* dynamic tenant migration

⸻

Architectural Rationale

Tenant isolation belongs to runtime enforcement.

Administration and visibility belong to user interaction.

Separating backend isolation from UI management preserves deterministic execution behavior.



