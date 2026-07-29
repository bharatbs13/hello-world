# Mathematical Equivalence Audit Instructions

## Objective

Compare two versions of the same technical document.

- **`before`** is the **implementation-ready frozen document** and is the sole mathematical authority.
- **`after`** is a derived Markdown-compatible version whose sole purpose is to correct Markdown mathematical rendering issues while preserving the exact mathematical content of `before`.

The objective of this audit is to determine whether **every mathematical expression in `after` is mathematically identical to the corresponding expression in `before`.**

This is **not**:

- a design review;
- an implementation review;
- a proofreading exercise;
- a style review;
- a notation improvement exercise.

Treat `before` as the authoritative mathematical specification.

Any mathematical difference in `after` is a defect unless it is strictly required for Markdown rendering compatibility and does not alter mathematical meaning.

---

# Scope

Audit **only mathematical semantic equivalence**.

Assume the implementation-ready frozen `before` document is mathematically correct.

Verify that every mathematical object appearing in `before` is represented identically in `after`.

Do **not** evaluate:

- implementation quality;
- engineering decisions;
- algorithm design;
- wording;
- grammar;
- prose style;
- formatting preferences;
- notation preferences;
- readability improvements.

Evaluate only whether the mathematical meaning has been preserved exactly.

---

# Permitted Differences

The following presentation-only changes are acceptable provided the mathematical meaning is unchanged.

## Mathematical Delimiters

- `\(...\)` → `$...$`
- `\[...\]` → `$$...$$`

---

## Bracing

Additional braces added only for parser clarity.

Examples:

- `X_{i,t}`
- `^{\top}`
- `\widetilde{X}`

---

## Renderer-Compatible Typography

Examples include:

- `\operatorname` → `\mathrm`
- renderer-compatible escaping of literal underscores
- Unicode mathematical notation inside Markdown tables
- Unicode Greek letters
- Unicode hats
- Unicode transpose
- Unicode inequalities
- Unicode truth markers
- textual `(n choose 2)` replacing `\binom{n}{2}` inside Markdown tables when required for renderer compatibility

---

## Formatting

Presentation-only changes such as:

- whitespace;
- indentation;
- line wrapping;
- Markdown table layout;
- display formatting.

---

# Forbidden Changes

Any change to mathematical meaning is a failure.

Examples include:

- renaming variables;
- renaming symbols;
- changing identifiers;
- changing indices;
- changing subscripts;
- changing superscripts;
- changing transpose;
- changing inverse;
- changing constants;
- changing coefficients;
- changing thresholds;
- changing operators;
- changing equalities;
- changing inequalities;
- changing functions;
- changing summation limits;
- changing product limits;
- changing integration limits;
- changing matrix multiplication order;
- changing projection definitions;
- changing tuple members;
- changing set definitions;
- changing piecewise branch order;
- changing branch conditions;
- changing evaluation order;
- simplifying expressions;
- expanding expressions;
- algebraically rearranging expressions;
- introducing new mathematical notation;
- introducing aliases for existing mathematical quantities;
- replacing one mathematical expression with another mathematically equivalent expression.

The audit concerns **mathematical identity**, not merely mathematical equivalence.

---

# Audit Methodology

Perform the audit in multiple passes.

Each pass shall compare every mathematical expression within its assigned scope.

For every expression:

1. Quote or summarize the corresponding expression from `before`.
2. Quote or summarize the corresponding expression from `after`.
3. Compare:
   - variables;
   - symbols;
   - indices;
   - subscripts;
   - superscripts;
   - constants;
   - coefficients;
   - operators;
   - functions;
   - equalities;
   - inequalities;
   - matrix dimensions;
   - multiplication order;
   - transpose/inverse operations;
   - summation or product limits;
   - logical conditions;
   - set definitions;
   - tuple members.
4. Determine whether the mathematical object represented is identical.
5. Record a PASS or FAIL for that expression.

Each audit pass shall conclude with a PASS or FAIL summary.

Continue auditing all remaining sections even if defects are found.

---

# Recommended Audit Passes

## Pass 1 — Core Definitions and Preprocessing

Compare:

- symbol definitions;
- input representations;
- preprocessing equations;
- scaling equations;
- parameter mappings;
- preprocessing output contracts.

---

## Pass 2 — Core Mathematical Model

Compare:

- graph construction;
- correlation definitions;
- threshold inequalities;
- optimization equations;
- state equations;
- estimation equations;
- statistical tests;
- canonical transformations;
- normalization equations.

---

## Pass 3 — Public Interfaces and Schemas

Compare:

- configuration parameters;
- API mathematical definitions;
- schema dimensions;
- matrix dimensions;
- mathematical fields in output contracts;
- mathematical expressions inside Markdown tables.

---

## Pass 4 — Evaluation and Qualification

Compare:

- evaluation profiles;
- qualification gates;
- acceptance thresholds;
- projection formulas;
- norm definitions;
- statistical metrics;
- mathematical conditions;
- qualification equations.

---

## Pass 5 — Remaining Mathematical Content

Compare:

- informative metrics;
- appendix mathematics;
- derived equations;
- concluding mathematical statements;
- remaining mathematical expressions not covered in previous passes.

---

# Final Cross-Pass Verification

Perform a complete document-wide verification.

Confirm:

- every mathematical expression from `before` has been audited;
- no mathematical expression has been omitted;
- no new mathematical object has been introduced;
- no mathematical object has been removed;
- all variables remain identical;
- all symbols remain identical;
- all indices remain identical;
- all constants remain identical;
- all coefficients remain identical;
- all operators remain identical;
- all functions remain identical;
- all equalities remain identical;
- all inequalities remain identical;
- all matrix dimensions remain identical;
- all matrix multiplication orders remain identical;
- all transpose and inverse operations remain identical;
- all summation, product, and integration limits remain identical;
- all logical conditions remain identical;
- all set definitions remain identical;
- all tuple members remain identical;
- all piecewise definitions remain identical.

---

# Final Certification

Conclude with one of the following.

## PASS

The `after` document is mathematically identical to the frozen `before` document.

All observed differences are limited to Markdown mathematical rendering compatibility, including delimiter conversion, renderer-compatible typography, Unicode mathematical notation, bracing, whitespace, indentation, line wrapping, and display formatting.

No mathematical object, variable, symbol, operator, coefficient, threshold, function, relationship, or mathematical meaning has changed.

---

## FAIL

List every mathematical defect individually.

For each defect provide:

- location;
- expression in `before`;
- expression in `after`;
- precise mathematical difference;
- impact on mathematical meaning;
- required correction.

Do not stop after the first defect. Report all mathematical defects found.
