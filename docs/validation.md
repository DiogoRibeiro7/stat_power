# Numerical validation

`stat_power` treats numerical validation as part of the public contract.

## CRAN pwr reference fixtures

The first compatibility target is CRAN `pwr` 1.3-0. Reference cases live in
`spec/fixtures/pwr_parity.yml` and are exercised by
`spec/parity/pwr_parity_spec.rb`.

The fixture set deliberately uses public examples from the `pwr` reference
manual and Cohen (1988) where available. It covers every power-analysis family
implemented by `stat_power`, including both direct power calculations and
representative inverse problems.

The fixture file records:

- the corresponding `pwr` function,
- the source/example label,
- the Ruby public API call,
- the input arguments,
- the output field being checked,
- the expected numeric value,
- the accepted absolute tolerance.

Detailed unit tests remain alongside each implementation. The fixture suite is
an additional end-to-end compatibility layer, not a replacement for
distribution-level, solver-level, domain, or round-trip tests.

## Tolerance policy

Numerical tolerances are explicit per fixture.

As a default policy:

- direct probabilities and distribution values use absolute tolerances around
  `1e-8` or tighter when the reference is stable,
- inverse root solutions generally use `1e-5` because independent numerical
  solvers can stop at slightly different points while agreeing statistically,
- looser tolerances are used only when the published reference itself is
  reported with fewer digits.

A tolerance should not be widened merely to make a failing test pass. A change
must first be traced to one of:

1. a documented difference in the statistical model,
2. a known precision limit of the numerical method,
3. a reference value with limited published precision,
4. an implementation defect.

## Reproducibility

The fixture values are versioned with the code so changes are reviewable in
pull requests. Adding a new statistical family requires adding at least one
forward reference case and one inverse reference case when the reference API
supports inverse solving.

The project does not execute R during normal gem CI. This keeps the Ruby test
suite self-contained and deterministic while preserving explicit provenance
for the reference numbers.
