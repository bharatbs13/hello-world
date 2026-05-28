# FR-072 — Connector Security Governance

## Target Version
v0.6

## Scope

Defines governance and operational security controls for external connectors, SDKs, MCP integrations, and execution libraries.

This FR establishes connector-level security oversight within Relix.

Covers:

- connector allowlists
- version governance
- vulnerability-aware restrictions
- connector disablement
- policy quarantine
- runtime connector restrictions
- trusted connector registration
- governed connector lifecycle control

Does NOT yet cover:

- automated CVE remediation
- autonomous patch orchestration
- runtime binary attestation
- zero-trust distributed execution