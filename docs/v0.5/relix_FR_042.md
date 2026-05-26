FR-042 — Reporting UI & Subscription Management

Target Version

v0.5 Enterprise Collaboration Layer

⸻

Scope

Platform / UI

⸻

Objective

Provide UI and CLI interfaces for configuring reports, subscriptions, schedules, and delivery preferences.

⸻

Architecture

User
↓
Reporting UI / CLI
↓
Subscription Validator
↓
Report Configuration
↓
Delivery Framework

⸻

UI Capabilities

Report Management

Users can:

* create report subscriptions
* edit report subscriptions
* delete report subscriptions
* preview reports
* select report artifact formats
* select report consistency mode
* select report scope

Examples:

* workflow-level
* task-level
* connector-level
* organization-level
* historical range

⸻

Schedule Management

Users can configure:

* on completion
* on failure
* daily
* weekly
* monthly
* cron schedules

⸻

Delivery Configuration

Users can configure:

* email recipients
* webhook endpoints
* future channels

⸻

Subscription Visibility

Display:

* active subscriptions
* delivery history
* failures
* retry history
* report generation timestamp
* source timestamps
* consistency mode
* report retention status
* artifact expiration status
* subscription owner
* subscription visibility type

Examples:

Monthly reconciliation report

Created:
2026-05-01

Expires:
2026-11-01

Status:
Archived

Owner:
Operations Team

Visibility:
Organization

⸻

Validation Rules

Configurations must validate:

* recipient existence
* schedule validity
* permission requirements
* delivery endpoint validity
* supported artifact formats
* supported consistency modes
* subscription ownership rules
* shared subscription permissions
* organization visibility rules
* user has permission to subscribe recipients
* user has permission to access report scope
* user has permission to view historical reports

Examples:

Personal subscription:

visible only to creator

Shared subscription:

visible only to authorized users

Organization subscription:

visible according to workspace permissions

⸻

CLI Examples

relix reports create

relix reports subscribe

relix reports list

relix reports history

⸻

Acceptance Criteria

1. Users can manage report subscriptions.
2. Delivery configuration is supported.
3. Invalid schedules are rejected.
4. Delivery history is visible.
5. Permission boundaries are enforced.
6. Artifact format selection is supported.
7. Consistency mode selection is supported.
8. Report scope selection is supported.
9. Ownership and visibility rules are enforced.
10. CLI and UI remain behaviorally consistent.

⸻

Non-Goals

Not included:

* direct delivery bypass
* unrestricted recipient configuration
* autonomous subscription creation

⸻

Architectural Rationale

Reporting configuration belongs to collaboration and user interaction rather than workflow runtime execution.

Roadmap fit:

v0.3
Telemetry
↓
v0.5
Reporting Engine
↓
Reporting UI
↓
v0.6
AI summaries / explanations

