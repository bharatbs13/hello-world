# FR-073 — Scoped Session & Temporary Credential Management

## Target Version
v0.7

## Scope

Defines temporary and scoped credential/session management mechanisms for governed database access.

This FR introduces reduced credential lifetime and session-bound access models.

Covers:

- temporary access tokens
- session-scoped credentials
- connector session expiration
- revocable execution sessions
- time-bound access policies
- session isolation controls

Does NOT yet cover:

- enterprise federation
- distributed trust orchestration
- hardware-bound credentials
