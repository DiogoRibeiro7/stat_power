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

For compatibility and numerical validation, solvers retain the continuous
sample-size solution produced by the underlying power equation.

A result may additionally expose the smallest design-valid integer sample size
not below that solution. This distinction is explicit: continuous values are
useful for parity checks and mathematical work, while integer values are useful
for study design.

For two-group designs, total sample size and per-group sample size must be
distinguished explicitly in the public API and documentation.

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

Compatibility layers may accept reference-package spellings such as
`"two.sided"`, but results are normalised to the Ruby convention.

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

CRAN `pwr` is the initial compatibility target. Its documented statistical
models and numerical results are reference points, but `stat_power` uses an
independent native Ruby implementation.

Suitable additional references include peer-reviewed formulas, established
statistical textbooks, Python implementations, and published G*Power examples.

Agreement with another software package is evidence of consistency, not a substitute for verifying the underlying mathematics.
