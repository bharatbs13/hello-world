# Relix FR-032 — Application Ports & Adapter Architecture

## Target Version

v0.2

## Scope

Platform / Runtime Architecture

---

## Objective

Define a ports-and-adapters architecture so CLI, REST API, UI, workers, and future operational surfaces invoke Relix through stable application service ports instead of directly calling runtime internals.

CLI support should exist as an optional adapter, not as the primary architecture.

---

## Problem Statement

Relix will eventually support multiple interaction surfaces:

- CLI
- REST API
- Web UI
- worker controllers
- automation hooks
- future agentic assistants

If these surfaces call runtime internals directly, the platform risks:

- duplicated logic
- inconsistent authorization
- bypassed governance
- inconsistent validation
- difficult future UI/API integration

Relix needs stable application ports that all adapters use consistently.

---

## Architecture

```text
Core Runtime
    ↓
Application Service / Use-Case Port
    ↓
Adapters
    ├── CLI Adapter
    ├── REST API Adapter
    ├── UI Adapter
    ├── Worker Adapter
    └── Future Agent Adapter
```

---

## Design Pattern

Use:

Ports & Adapters / Hexagonal Architecture

Core rule:

Core exposes use-case ports.

Adapters call use-case ports.

Adapters do not bypass core policy or runtime boundaries.

---

## v0.2 Scope

In v0.2, implement the architecture foundation.

Deliverables:

- application service layer
- command/use-case ports
- CLI adapter over use-case ports
- runtime independent from CLI
- no UI required
- no REST API required

---

## Future Adapter Usage

Later versions may add:

### v0.3

REST API adapter using the same use-case ports.

### v0.4

UI adapter consuming API/application ports.

### v1.x

Distributed worker controls using the same application service layer.

---

## CLI Adapter Rule

CLI is a secondary adapter.

CLI commands may be added only as needed.

Examples:

- `relix workflow status`
- `relix workflow progress`
- `relix workflow pause`
- `relix workflow resume`

CLI must call application service ports.

CLI must not call runtime internals directly.

---

## Non-Goals

Not included:

- full REST API implementation
- Web UI implementation
- distributed worker implementation
- direct CLI-to-runtime mutation
- adapter-specific business logic
- bypassing policy checks
- bypassing approval gates

---

## Acceptance Criteria

1. Application service/use-case port layer exists.

2. CLI commands call application ports.

3. Runtime does not depend on CLI.

4. Runtime policy checks are not duplicated in adapters.

5. Future REST/UI adapters can reuse the same ports.

6. Adapter calls cannot bypass governance, RBAC, approval, or validation rules.
