# FR-067 — Secret Provider Abstraction Layer

## Target Version
v0.6

## Scope

Defines a unified abstraction layer for resolving and managing credentials from approved secret providers.

This FR standardizes how Relix internally retrieves credentials while isolating agents and connectors from provider-specific implementations.

Covers:

- secret-provider abstraction interfaces
- environment-based secrets
- vault integrations
- cloud secret manager integrations
- encrypted local credential stores
- provider-independent credential resolution
- secure in-memory secret handling
- provider registration/configuration

Does NOT yet cover:

- enterprise secret rotation orchestration
- distributed secret replication
- hardware-backed attestation
- HSM integration