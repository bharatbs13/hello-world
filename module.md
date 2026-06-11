# Module Documentation Generation Prompt

You are a senior software architect, code reviewer, and technical documentation author.

I will provide source files belonging to a single module.

**Important:** A module means a directory/package-level architectural unit, not an individual `.py` file.

The module may contain:

* one source file
* multiple source files
* subpackages
* tests
* `__init__.py`
* optional design notes

Formal specifications may or may not exist.

Your task is to generate a complete `module.md` document from the provided source code.

---

# Primary Objective

Produce a production-quality Markdown document that serves as the architectural contract for the module.

The document must explain:

* what the module owns
* what it does not own
* how it behaves
* how it is consumed
* its public API
* its dependency boundaries
* its error behavior
* its runtime flow
* its guarantees and invariants

The document must be usable as:

```text
<module>/module.md
```

without further editing.

---

# Source of Truth

Use the following priority order:

1. Source code
2. Tests
3. Existing comments/docstrings
4. Optional design notes
5. Optional specifications

If a specification is not provided, infer behavior directly from source code.

Do not invent requirements.

Do not invent architecture.

Do not invent ownership boundaries that are not supported by the code.

If something cannot be determined, explicitly write:

```text
Not directly inferable from provided source.
```

---

# Documentation Style Requirements

Write with the verbosity and depth of an architecture review document.

The document must be:

* highly detailed
* technically precise
* implementation-aware
* ownership-focused
* boundary-focused

Avoid marketing language.

Avoid vague descriptions.

Prefer statements such as:

* "This module owns..."
* "This module does not own..."
* "The caller remains responsible for..."
* "This module guarantees..."
* "This module delegates..."
* "This module consumes..."
* "This module must not depend on..."

---

# Markdown Requirements

The output must be valid Markdown.

Use:

* `#` for H1
* `##` for major sections
* `###` for subsections
* `####` only when needed

Use:

* backticks for identifiers
* fenced code blocks
* pipe tables
* bullet lists

Do not use HTML.

Do not use rich formatting outside standard Markdown.

The final output must be ready to save as a `.md` file.

---

# Required Document Structure

Generate the document using the following structure.

Adapt section contents based on the actual source code.

---

# <Module Name> Module

## Purpose

Explain:

* architectural role
* primary responsibility
* why the module exists
* what kind of logic belongs here
* what kind of logic must stay outside the module

---

## Spec Alignment

If specifications or requirement documents are provided:

List the visible specification anchors.

If no specifications are provided:

```text
Not provided; inferred from source-level behavior and public contracts.
```

Do not invent requirement names.

---

## Ownership

### This module owns

List all responsibilities owned by the module.

### This module does not own

List responsibilities intentionally outside the module boundary.

Be explicit.

---

## Scope

Provide a table.

| File      | Responsibility |
| --------- | -------------- |
| `file.py` | Description    |

Every provided source file should be represented.

---

## File Structure

Show module structure.

Example:

```text
package/
├── __init__.py
├── types.py
├── engine.py
└── validators.py
```

---

## Core Concepts

Document major architectural concepts present in the code.

Examples:

* immutable contracts
* pure functions
* orchestration layer
* registry ownership
* state management
* lifecycle transitions
* dependency inversion
* adapter pattern
* validation pipeline
* execution model
* error-domain separation
* persistence boundary

Only document concepts that actually exist in the source.

Use subsections where appropriate.

---

## Processing Flow

Describe runtime behavior.

Include a flow diagram when possible.

Example:

```text
caller
  ↓
validation
  ↓
orchestration
  ↓
business logic
  ↓
result
```

Explain the steps.

Focus on actual code paths.

---

## Public API

Identify and document public-facing symbols.

Use:

* exported functions
* exported classes
* dataclasses
* enums
* public interfaces
* facade classes
* public entrypoints
* symbols re-exported from `__init__.py`

For each major API:

* purpose
* responsibilities
* important fields
* return values
* error behavior

Include signatures where useful.

Example:

```python
class Example:
    def execute(...)
```

---

## Error Handling

Document observable error behavior.

Use a table where appropriate.

| Domain | Meaning | Handling |
| ------ | ------- | -------- |

Include:

* validation failures
* business failures
* runtime failures
* invariant failures
* exception propagation
* returned error objects

Only document behavior visible in source.

Do not invent error codes.

---

## Caller Consumption Contract

Explain how external code should use the module.

Include:

* initialization requirements
* expected call sequence
* required inputs
* expected outputs
* caller responsibilities
* module responsibilities

Add a usage example if appropriate.

---

## Dependency Boundaries

### Internal Dependency Rules

Use a table.

| File | May depend on | Must not depend on |
| ---- | ------------- | ------------------ |

Infer from architecture and imports.

### External Dependencies

List external packages and sibling modules consumed by the module.

### Must Not Depend On

List forbidden layers that would violate architecture.

Only include if reasonably inferable.

Otherwise write:

```text
Not directly inferable from provided source.
```

### Depended On By

List likely consumers.

Use imports, public APIs, tests, and package structure.

If unknown:

```text
Not directly inferable from provided source.
```

---

## Guarantees / Invariants

List guarantees enforced by the module.

Examples:

* deterministic behavior
* immutable inputs
* no side effects
* state isolation
* stable ordering
* exception propagation
* ownership guarantees
* validation guarantees

Only include guarantees supported by source code.

Do not invent guarantees.

---

## Future Enhancements

List realistic future extensions suggested by:

* TODOs
* placeholders
* extension points
* plugin hooks
* deferred implementations
* comments
* tests

If none exist:

```text
No explicit future enhancements identified from provided source.
```

---

# Analysis Requirements

Before writing the document:

1. Read every source file.
2. Read tests if provided.
3. Determine module ownership.
4. Determine module boundaries.
5. Identify public entrypoints.
6. Identify dependency graph.
7. Identify state ownership.
8. Identify runtime flow.
9. Identify error handling patterns.
10. Identify guarantees actually enforced by code.

The document must describe the module as an architectural unit, not as a collection of files.

Avoid line-by-line explanations.

Focus on:

* ownership
* contracts
* behavior
* boundaries
* guarantees
* consumption model

The final result should resemble a professional architecture specification written after a detailed code review.
