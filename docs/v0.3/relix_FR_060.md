# FR-060 — Invite-Based Identity & Email Authentication Framework

## Target Version

`v0.3`

## Scope

Platform / Identity

## Status

Proposed

## Objective

Introduce an invite-based identity and authentication framework for Relix.

The framework must support:

- Invite-based onboarding
- User identity creation
- Organization membership assignment
- Email OTP verification
- Authenticated sessions
- Secure login lifecycle

The framework establishes user identity foundations before authorization and enterprise RBAC are introduced.

## Problem Statement

Relix requires controlled access onboarding for customers and users.

Open registration creates risks:

- Unauthorized access
- Uncontrolled organization creation
- Inconsistent onboarding
- Weak identity validation
- Difficult enterprise governance

Relix should support controlled invitation and identity verification.

## Architecture

```text
Relix Platform Admin
        |
        v
Organization Invite
        |
        v
User Signup
        |
        v
Email OTP Verification
        |
        v
Identity Creation
        |
        v
Session Creation
```

## Core Components

Identity service defines:

- `User`
- `Organization`
- `Invite`
- `Membership`
- `OTPChallenge`
- `Session`

## Invite Flow

```text
Relix Admin
    |
    v
Invite Customer Organization Admin

Customer Organization Admin
    |
    v
Invite Organization Members

User
    |
    v
Receives Email Invite
    |
    v
Signup
    |
    v
Email OTP Verification
    |
    v
Account Activation
```

## Identity Rules

- Email verification is required.
- Invite tokens must expire.
- Invite tokens must be single-use.
- OTP challenges must expire.
- Session tokens must expire.
- Identity state changes must be event-backed.

## Session Lifecycle

```text
CREATED
   |
   v
VERIFIED
   |
   v
AUTHENTICATED
   |
   v
EXPIRED
```

## Non-Goals

Not included:

- RBAC
- SSO
- External identity providers
- Social login
- Organization policy rules
- Enterprise governance

## Acceptance Criteria

| ID | Criteria |
|----|----------|
| `AC-1` | Invite workflow exists |
| `AC-2` | Invite tokens are single-use and expirable |
| `AC-3` | Email OTP verification exists |
| `AC-4` | User identity creation exists |
| `AC-5` | Membership assignment exists |
| `AC-6` | Authenticated session lifecycle exists |
| `AC-7` | Identity events are persisted |