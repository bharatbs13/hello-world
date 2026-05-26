FR-049 — Agent Instruction Hierarchy & Human Override Policy
Target Version
v0.6 Intelligent Platform

Scope
Platform / Intelligence Governance

Objective
Provide deterministic precedence rules governing agents, humans, governance rules, and platform constraints.

Instruction Hierarchy
Platform Constraints ↓ Governance Policies ↓ Frozen Execution Plan ↓ Human Approved Configuration ↓ Current User Instruction ↓ Agent Recommendation
Higher levels always override lower levels.

Human Override Rules
Users may override:
* recommendations
* workflow suggestions
* optimization suggestions
Only when:
* permissions exist
* governance permits override
* actions are audited

Restrictions
Users cannot override:
* platform constraints
* governance rules
* frozen plans
* deterministic runtime rules
Agents cannot override:
* platform constraints
* governance policies
* runtime behavior

Acceptance Criteria
1. Instruction precedence is deterministic.
2. Human overrides remain permission controlled.
3. Overrides remain auditable.
4. Runtime determinism remains unchanged.


