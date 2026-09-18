# Mathematical conventions

This document defines the conventions that all implementations in `stat_power` must follow.

## Probability and significance

The significance level is denoted by \(\alpha\), with \(0 < \alpha < 1\).

Statistical power is

\[
1 - \beta,
\]

where \(\beta\) is the Type II error probability.

Unless a method explicitly states otherwise, two-sided tests split \(\alpha\) equally across both tails.

## Sample size

A sample size is always reported as an integer and must satisfy the constraints of the design.

When a numerical solution is non-integer, the library rounds upward to the smallest design-valid integer that attains at least the requested power.

For two-group designs, total sample size and per-group sample size must be distinguished explicitly in the public API and documentation.

## Effect sizes

Standardised effect sizes follow conventional definitions:

- Cohen's \(d\) for standardised mean differences
- Cohen's \(h\) for differences between proportions on the arcsine scale
- Cohen's \(f\) for ANOVA
- Cohen's \(f^2\) for regression
- Cohen's \(w\) for chi-square tests

Conversions must document their assumptions and must not silently assume interchangeable effect-size definitions.

## Tail conventions

Alternatives use explicit names:

- `two_sided`
- `greater`
- `less`

Methods must not infer direction from the sign of an effect size unless that behaviour is mathematically intrinsic and documented.

## Numerical solving

Inverse power problems are solved numerically only when a closed-form expression is unavailable or undesirable.

Root-finding routines must:

1. define a mathematically valid search interval,
2. verify that the requested solution is identifiable,
3. fail clearly when the target cannot be bracketed,
4. expose deterministic tolerances,
5. be covered by reference-value tests.

## Precision and tolerances

Reference comparisons must distinguish between:

- exact algebraic identities,
- floating-point agreement,
- agreement with external software that uses different numerical algorithms.

Tolerance values belong in tests or numerical configuration, not as undocumented magic constants.

## Validation

Every implemented test family must include at least one independently reproducible validation source, preferably two.

Suitable references include peer-reviewed formulas, established statistical textbooks, R implementations, Python implementations, and published G*Power examples.

Agreement with another software package is evidence of consistency, not a substitute for verifying the underlying mathematics.
