# Markdown Mathematical Rendering Remediation Instructions

## Objective

Convert a mathematically complete technical document into a Markdown-compatible version that renders mathematical expressions correctly while preserving **100% mathematical equivalence** with the source.

The output is a **rendering-compatible transcription**, **not** a mathematical rewrite.

The source document is the mathematical authority.

Only presentation required for Markdown mathematical rendering compatibility may change.

---

# Scope

Correct only Markdown mathematical rendering issues.

Do not modify:

- mathematical meaning;
- variables;
- symbols;
- identifiers;
- equations;
- inequalities;
- equalities;
- constants;
- coefficients;
- thresholds;
- parameter domains;
- feature identities;
- state definitions;
- action definitions;
- logical conditions;
- policy behaviour;
- implementation requirements.

Everything outside mathematical rendering shall remain unchanged unless required for Markdown compatibility.

---

# General Principles

The remediation philosophy is:

1. Preserve the original mathematics.
2. Preserve the original notation whenever it already renders correctly.
3. Apply the **minimum presentation-only change** required for correct Markdown rendering.
4. Never rewrite mathematics solely for stylistic consistency.

Do not normalize mathematical notation if the original already renders correctly.

---

# 1. Mathematical Delimiters

Use only:

Inline mathematics

```latex
$...$
```

Display mathematics

```latex
$$
...
$$
```

Replace:

```latex
\(...\)
```

with

```latex
$...$
```

Replace:

```latex
\[...\]
```

with

```latex
$$
...
$$
```

Never place mathematical expressions inside fenced code blocks.

---

# 2. Display Equation Layout

Preserve the original display-equation layout whenever possible.

Rules:

- Preserve the original equation layout.
- If the source equation occupies a single line, keep it on a single line.
- Do not split equations across multiple lines unless required for rendering.
- Do not split textual mathematical definitions into multiple fragments unless the target renderer requires it.
- Preserve the original visual structure of equations whenever possible.

Prefer:

```latex
$$
P_{i,t} = \text{adjusted close price of symbol } i \text{ at bar } t
$$
```

over

```latex
$$
P_{i,t}
=
\mathrm{adjusted\ close\ price\ of\ symbol}\ i\
\mathrm{at\ bar}\ t
$$
```

This is a presentation-preserving rule only.

It must never alter mathematical meaning.

---

# 3. Compound Subscripts and Superscripts

Always brace compound indices and superscripts.

Correct:

```latex
M_{P,i}

A_{i,j}^{(k)}

C_{i,t+h}^{\mathrm{px}}

\widetilde{X}_{i,t}

D^{\top}
```

Avoid:

```latex
M_P,i

A_i,j^k

C_i,t+h^px

\widetilde X_{i,t}

D^\top
```

Bracing is a parser clarification only.

It must never rename symbols or alter mathematical meaning.

---

# 4. Mathematical Functions

Preserve the original mathematical function whenever it renders correctly.

Use renderer-supported built-in functions.

Examples:

```latex
\min

\max

\log

\exp

\sin

\cos

\sqrt
```

If the renderer does not support:

```latex
\operatorname
```

replace only with an equivalent renderer-supported form such as:

```latex
\mathrm
```

Examples:

```latex
\operatorname{diag}
→
\mathrm{diag}

\operatorname{corr}
→
\mathrm{corr}

\operatorname{sign}
→
\mathrm{sign}
```

Do not replace one mathematical function with another.

---

# 5. Text Inside Mathematics

Preserve existing textual mathematics whenever it already renders correctly.

Prefer preserving:

```latex
\text{...}
```

if the target Markdown renderer supports it.

Replace:

```latex
\text{...}
```

with

```latex
\mathrm{...}
```

only when:

- the renderer does not support `\text`;
- the original expression fails to render correctly; or
- renderer compatibility requires the change.

Do not rewrite textual mathematical definitions merely for stylistic consistency.

For example, preserve:

```latex
$$
P_{i,t}
=
\text{adjusted close price of symbol } i
\text{ at bar } t
$$
```

if it renders correctly.

Do not split descriptive text into multiple `\mathrm{}` groups unless required by the renderer.


# 5A. Math Renderer Compatibility — Identifiers with Underscores

Configuration keys, API fields, schema names, enum values, implementation identifiers, and similar literals may legitimately contain underscores.

When such identifiers appear inside mathematical expressions (for example inside `\text{...}`), preserve the identifier exactly while ensuring correct rendering in the target Markdown renderer.

Rules:

- Preserve the original mathematical meaning.
- Preserve the identifier spelling exactly.
- Preserve every underscore exactly.
- Do not replace underscores with spaces.
- Do not replace underscores with hyphens.
- Do not rename the identifier.
- Do not abbreviate the identifier.
- Do not replace the identifier with a mathematical alias (for example `m`) unless explicitly requested by the user or unless no renderer-compatible representation exists.

If the target Markdown renderer requires Markdown-level escaping before LaTeX processing, use the minimum renderer-compatible escaping required for literal underscores.

For example, if one preprocessing layer consumes a backslash, the Markdown source may require:

```latex
\text{minimum\\_observation\\_ratio}
```

to render as

```text
minimum_observation_ratio
```

If the renderer correctly supports standard LaTeX escaping, prefer:

```latex
\text{minimum\_observation\_ratio}
```

Always use the **minimum escaping required by the target renderer**.

Renderer-compatible escaping is a presentation-only compatibility fix.

It is **not** a mathematical modification.

---

## Example

Preferred (when one Markdown escape layer is consumed):

```latex
$$
\frac{T}{N_k}
\ge
\text{minimum\\_observation\\_ratio}
\quad
(\text{default }10.0)
$$
```

Preferred (when standard LaTeX escaping is supported):

```latex
$$
\frac{T}{N_k}
\ge
\text{minimum\_observation\_ratio}
\quad
(\text{default }10.0)
$$
```

Do **not** rewrite as:

```latex
$$
\frac{T}{N_k}\ge m
$$
```

where

```text
m = minimum_observation_ratio
```

Introducing aliases changes the notation and is outside the scope of rendering-only remediation.

---

# 6. Visible Mathematical Sets

Use ordinary visible braces.

Preferred:

```latex
\{
...
\}
```

Avoid renderer-specific sizing commands unless required by the target renderer.

Examples:

```latex
A
=
\{
a,b,c
\}
```

Do not replace visible mathematical sets with prose.

---

# 7. Superscripts and Special Symbols

Always brace compound superscripts.

Examples:

```latex
^{\ast}

^{\circ}

^{\top}

^{-1}
```

Never generate malformed superscripts such as:

```latex
^*

^_
```

Use proper mathematical symbols:

```latex
90^{\circ}

\infty

^{\ast}
```

rather than ASCII approximations.

---

# 8. Logical Notation

Preserve the original logical meaning.

Where logical expressions are represented mathematically, use standard mathematical operators.

| Source | Mathematical Form |
|--------|-------------------|
| AND | `\land` |
| OR | `\lor` |
| NOT | `\neg` |
| implies | `\implies` |
| iff | `\iff` |
| belongs to | `\in` |

Do not alter logical precedence.

Do not simplify logical expressions.

Do not reorder conditions.

---

# 9. Piecewise Definitions

Represent piecewise functions using:

```latex
\begin{cases}
...
\end{cases}
```

Use literal alignment characters:

```latex
&
```

Never:

```latex
&amp;
```

Preserve exactly:

- branch order;
- branch conditions;
- returned values;
- precedence.

Do not merge branches.

Do not simplify branches.

---

# 10. Tuples

Represent tuples using standard mathematical notation.

Example:

```latex
$$
(a,b,c,d)
$$
```

or

```latex
$$
\Big(
a,b,c,d
\Big)
$$
```

when larger delimiters are supported.

Do not:

- reorder tuple members;
- insert new members;
- remove members;
- rename members.

Tuple structure is part of the mathematical specification and must remain unchanged.


# 11. Mathematical Expressions Inside Markdown Tables

Many Markdown renderers have limited or inconsistent support for LaTeX inside table cells.

For maximum compatibility, mathematical expressions inside Markdown tables should be represented using equivalent Unicode mathematical notation rather than LaTeX.

This conversion is **presentation only**.

It must preserve the exact mathematical meaning.

---

## General Rules

Inside Markdown tables:

- do not use `$...$` or `$$...$$`;
- convert LaTeX mathematics into equivalent Unicode mathematical notation;
- preserve the mathematical meaning exactly;
- preserve variable names and identifiers exactly;
- preserve operator precedence;
- preserve mathematical relationships.

Outside Markdown tables, continue using normal LaTeX mathematics.

---

# 12. Unicode Mathematical Notation

Use standard Unicode mathematical symbols whenever available.

Examples:

| LaTeX | Table Representation |
|-------|----------------------|
| `\Pi` | Π |
| `\Sigma` | Σ |
| `\Delta` | Δ |
| `\alpha` | α |
| `\beta` | β |
| `\gamma` | γ |
| `\mu` | μ |
| `\sigma` | σ |
| `\rho` | ρ |
| `\tau` | τ |
| `\phi` | φ |
| `\varepsilon` | ε |
| `\times` | × |
| `\le` | ≤ |
| `\ge` | ≥ |
| `\ne` | ≠ |
| `\approx` | ≈ |
| `\rightarrow` | → |
| `\leftarrow` | ← |
| `^\top` | ᵀ |
| `^\ast` | ⋆ (or * where Unicode is unavailable) |
| `\cdots` / `\dots` | … |

Preserve the mathematical object exactly.

---

# 13. Typical Table Conversions

Examples of renderer-compatible conversions.

| LaTeX | Table Representation |
|-------|----------------------|
| `$r$` | r |
| `$r = 1$` | r = 1 |
| `$r > 1$` | r > 1 |
| `$N_k \times r$` | Nₖ × r |
| `$\Pi = \alpha\beta^\top$` | Π = αβᵀ |
| `$S_t$` | Sₜ |
| `$Z_t$` | Zₜ |
| `$r = 0,1,\dots$` | r = 0, 1, … |
| `$\frac{T}{N_k}$` | T/Nₖ |
| `$2^{32}$` | 2³² (or 2^32 where Unicode superscripts are unavailable) |

These are presentation-only conversions.

---

# 14. Binomial Coefficients

When Markdown tables cannot reliably render

```latex
\binom{n}{2}
```

represent the same quantity using:

```text
(n choose 2)
```

Examples:

```text
Σₖ (│Cₖ│ choose 2) / (N choose 2)
```

Do not change the mathematical meaning.

Do not replace with an approximation.

---

# 15. Matrix Dimensions

Represent matrix dimensions using Unicode multiplication.

Example:

```text
Nₖ × r
```

rather than

```latex
N_k \times r
```

Do not alter the dimensions.

---

# 16. Matrix Expressions

Represent matrix relationships using Unicode mathematical notation.

Examples:

```text
Π = αβᵀ

Π̂

β̂

β⋆
```

Preserve:

- transpose;
- multiplication order;
- hats;
- truth markers;
- matrix identities.

Do not rewrite matrix equations.

---

# 17. Mathematical Semantic Preservation

The source document is the mathematical authority.

Every mathematical expression must represent **exactly the same mathematical object** after remediation.

Presentation-only changes are permitted.

These include:

- Markdown delimiter conversion;
- parser bracing;
- renderer-compatible typography;
- renderer-compatible escaping;
- Unicode mathematical notation inside Markdown tables;
- whitespace;
- indentation;
- line wrapping;
- Markdown formatting.

The following are strictly prohibited:

- renaming variables;
- renaming symbols;
- changing identifiers;
- changing indices;
- changing subscripts;
- changing superscripts;
- changing constants;
- changing coefficients;
- changing operators;
- changing functions;
- changing equalities;
- changing inequalities;
- changing logical operators;
- changing evaluation order;
- changing summation limits;
- changing product limits;
- changing integration limits;
- changing matrix multiplication order;
- changing matrix dimensions;
- changing set definitions;
- changing tuple members;
- changing piecewise branches;
- changing branch conditions;
- simplifying expressions;
- expanding expressions;
- algebraic rearrangement;
- introducing aliases for existing mathematical quantities.

Every mathematical expression in the remediated document shall denote exactly the same mathematical object as in the source document.

# Verification

After remediation, perform a complete verification of the corrected Markdown document.

The purpose of verification is to ensure:

1. Markdown mathematical syntax is valid.
2. Mathematical rendering is compatible with the target renderer.
3. Every mathematical expression is semantically identical to the source.
4. No unintended mathematical modifications have been introduced.

---

# A. Mathematical Syntax Validation

Verify all mathematical environments.

Confirm:

- balanced `$...$` delimiters;
- balanced `$$...$$` delimiters;
- balanced `{}` braces;
- matching `\begin{cases}` / `\end{cases}`;
- matching `\begin{matrix}` / `\end{matrix}` where applicable;
- matching `\begin{aligned}` / `\end{aligned}` where applicable;
- valid superscripts;
- valid subscripts;
- no empty mathematical environments;
- no malformed LaTeX commands.

Confirm that unsupported syntax has been removed when required by the target renderer.

Examples include:

- `\(`
- `\)`
- `\[`
- `\]`
- unsupported `\operatorname`
- malformed `^*`
- malformed `^_`
- `&amp;`

---

# B. Renderer Compatibility Validation

Verify that every mathematical expression is compatible with the intended Markdown renderer.

Confirm:

- inline mathematics renders correctly;
- display mathematics renders correctly;
- multiline equations render correctly;
- piecewise equations render correctly;
- matrices render correctly;
- delimiters render correctly;
- equations do not break unexpectedly;
- equations preserve their intended layout.

Display equations that originally occupied a single line should remain on a single line whenever possible.

Do not introduce unnecessary line breaks.

---

# C. Renderer Compatibility Validation — Escaped Identifiers

Inspect every mathematical identifier containing literal underscores.

Examples include:

- configuration keys;
- API fields;
- schema names;
- enum values;
- implementation identifiers.

Verify:

- every underscore renders as exactly one visible underscore;
- no visible backslashes appear in the rendered output;
- identifier spelling is unchanged;
- no accidental mathematical subscripts are introduced;
- no parser errors remain (for example "_ allowed only in math mode");
- no identifier has been renamed;
- no identifier has been replaced with an alias.

Renderer-compatible escaping (for example `\\_` instead of `\_` when required by the target platform) is a presentation-only compatibility fix.

It must **not** be reported as a mathematical modification.

---

# D. Markdown Table Validation

Verify every Markdown table.

Confirm:

- table structure is valid;
- columns remain aligned;
- mathematical expressions have been converted into renderer-compatible Unicode notation where required;
- variables remain unchanged;
- dimensions remain unchanged;
- operators remain unchanged;
- matrix expressions remain unchanged;
- Unicode mathematical symbols represent exactly the same mathematical objects.

Typical checks include:

- Π
- Σ
- Δ
- β̂
- Π̂
- β⋆
- ≤
- ≥
- ≠
- ×
- ᵀ
- …
- (n choose 2)

Table rendering must preserve mathematical meaning exactly.

---

# E. Mathematical Equivalence Validation

Compare every mathematical expression against the source.

Verify that each expression preserves:

- variables;
- identifiers;
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
- logical operators;
- evaluation order;
- matrix dimensions;
- matrix multiplication order;
- transpose operations;
- inverse operations;
- summation limits;
- product limits;
- integration limits;
- tuple members;
- set definitions;
- piecewise branches;
- branch conditions.

Every mathematical object must remain identical.

---

# F. Structural Validation

Verify document structure.

Confirm:

- all mathematical sections remain present;
- section ordering is unchanged;
- mathematical figures remain associated with the correct sections;
- mathematical tables remain associated with the correct sections;
- no mathematical content has been omitted;
- no mathematical content has been duplicated.

---

# G. Final Rendering Checklist

Confirm all of the following:

✓ Mathematical expressions render correctly.

✓ Inline mathematics renders correctly.

✓ Display mathematics renders correctly.

✓ Programming identifiers render correctly.

✓ Literal underscores render correctly.

✓ No visible escaping characters remain.

✓ Markdown tables render correctly.

✓ Unicode mathematical notation renders correctly.

✓ No parser errors remain.

✓ Mathematical meaning is identical to the source.

---

# H. Certification

Conclude the remediation with an explicit certification.

Example:

> **Rendering Compatibility Certification**
>
> The document has been remediated solely for Markdown mathematical rendering compatibility.
>
> All mathematical expressions have been verified against the source document.
>
> Differences are limited to presentation-only changes, including delimiter conversion, parser bracing, renderer-compatible typography, renderer-compatible escaping, Unicode mathematical notation within Markdown tables, whitespace, indentation, line wrapping, and Markdown formatting.
>
> No variable, identifier, symbol, coefficient, constant, operator, function, threshold, matrix relationship, logical condition, or mathematical meaning has been modified.


# Final Output Requirements

The remediated document shall remain a faithful Markdown-compatible transcription of the source document.

Its purpose is solely to improve Markdown mathematical rendering compatibility.

It shall **not** become a rewritten, reformatted, simplified, or mathematically revised version of the source.

---

# Verbatim Preservation

Except where mathematical rendering compatibility requires a presentation-only change, preserve the source document verbatim.

Do not modify:

- document title;
- version;
- status;
- section numbering;
- section ordering;
- implementation notes;
- normative statements;
- requirements;
- algorithms;
- parameter descriptions;
- configuration descriptions;
- API descriptions;
- explanatory prose;
- examples;
- acceptance criteria;
- implementation guidance.

Do not rewrite prose merely for style or readability.

---

# Mathematical Formula Inventory

Before producing the final document, verify that every mathematical expression appearing in the source document also appears in the remediated document.

Confirm:

- no formula has been omitted;
- no formula has been duplicated;
- no formula has been introduced;
- no mathematical statement has been removed.

Every source formula shall have exactly one corresponding formula in the remediated document.

---

# Presentation-Only Change Verification

Confirm that every mathematical modification belongs to one of the following categories only.

- Markdown delimiter conversion;
- parser bracing;
- renderer-compatible typography;
- renderer-compatible escaping;
- Unicode mathematical notation inside Markdown tables;
- whitespace;
- indentation;
- line wrapping;
- Markdown formatting.

No other mathematical modification is permitted.

---

# Mathematical Identity Checklist

Before finalizing the document, verify that every mathematical expression preserves:

- variables;
- identifiers;
- symbols;
- indices;
- subscripts;
- superscripts;
- constants;
- coefficients;
- parameters;
- operators;
- functions;
- equalities;
- inequalities;
- logical operators;
- evaluation order;
- transpose operations;
- inverse operations;
- matrix multiplication order;
- matrix dimensions;
- summation limits;
- product limits;
- integration limits;
- tuple members;
- set definitions;
- piecewise definitions;
- branch ordering;
- branch conditions.

Every mathematical object must remain identical to the source.

---

# Renderer Compatibility Checklist

Confirm:

- inline mathematics renders correctly;
- display mathematics renders correctly;
- display-equation layout is preserved whenever possible;
- equations originally written on one line remain on one line unless the renderer requires otherwise;
- programming identifiers render correctly;
- literal underscores render correctly;
- no visible backslashes remain in rendered identifiers;
- Markdown tables render correctly;
- Unicode mathematical notation renders correctly;
- no parser errors remain;
- no Markdown rendering artifacts remain.

Renderer-specific escaping (for example `\_` or `\\_`, depending on the target renderer) is considered a presentation-only compatibility fix.

It shall **not** be treated as a mathematical modification.

---

# Minimal-Change Principle

The remediation shall apply the **minimum presentation-only change** required for correct Markdown rendering.

If an existing mathematical expression already renders correctly:

- preserve it unchanged;
- do not normalize it;
- do not rewrite it;
- do not replace notation simply for stylistic consistency.

Rendering compatibility takes precedence over notation normalization.

---

# Prohibited Remediation Actions

Do not:

- rewrite mathematics for consistency;
- introduce mathematical aliases;
- replace implementation identifiers with symbolic variables;
- simplify equations;
- expand equations;
- rearrange equations;
- merge expressions;
- split expressions unnecessarily;
- rewrite working `\text{...}` expressions as `\mathrm{...}`;
- split single-line equations into multiple lines without necessity;
- replace working notation with alternative notation solely for style.

Only correct genuine Markdown mathematical rendering issues.

---

# Final Certification

Conclude the remediation with the following certification.

---

## Markdown Mathematical Rendering Certification

This document has been remediated solely to improve Markdown mathematical rendering compatibility.

The source document remains the mathematical authority.

Every mathematical expression has been preserved exactly.

Differences are limited to presentation-only rendering compatibility changes, including:

- Markdown delimiter conversion;
- parser bracing;
- renderer-compatible typography;
- renderer-compatible escaping;
- Unicode mathematical notation inside Markdown tables;
- whitespace;
- indentation;
- line wrapping;
- Markdown formatting.

No variable, identifier, symbol, equation, operator, coefficient, constant, threshold, function, logical condition, matrix relationship, or mathematical meaning has been modified.

The remediated document is mathematically identical to the source document while providing improved Markdown rendering compatibility.

