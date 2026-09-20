# Changelog

All notable changes to this project will be documented in this file.

## Unreleased

## 0.1.0.alpha.3 - 2026-09-20

### Added

- Contribution guide, code of conduct, and security policy
- Issue templates, including a dedicated numerical-discrepancy report
- Pull request template requiring independent numerical validation
- `CODEOWNERS` and Dependabot configuration for Bundler and GitHub Actions
- CodeQL analysis workflow
- `bin/setup` and `bin/console` developer scripts
- `rake verify` task running every check that CI runs
- Steep type checking of `lib/` against `sig/`, now enforced in CI
- SimpleCov line and branch coverage with an enforced minimum
- `.gitattributes`, `.editorconfig`, and `.ruby-version` for reproducible
  formatting and tooling across platforms

### Changed

- CI now runs lint, type check, and coverage as dedicated jobs, declares
  least-privilege permissions, and cancels superseded runs
- RuboCop runs with `NewCops: enable`
- Gem metadata now includes a contact address, bug tracker, and versioned
  source URI; maintainer-only files are no longer packaged

### Fixed

- **`sig/stat_power.rbs` shipped in 0.1.0.alpha.2 was not valid RBS.** The
  block signature for `PowerCurve.generate` used an unparenthesized union
  return type, so any consumer feeding the packaged signatures to `rbs` or
  Steep hit a parse error at line 282. Runtime behaviour was unaffected;
  0.1.0.alpha.1 was not affected, because it predates `PowerCurve`. `rbs
  validate` accepts the malformed form, which is why it reached a release;
  `steep check` now runs in CI and in the release gate.
- `EffectSize::ChiSquare.association` computed column marginals by mutating an
  accumulator array; it now uses `transpose`

## 0.1.0.alpha.2 - 2026-09-20

### Added

- Balanced one-way ANOVA power analysis compatible with `pwr.anova.test`
- Dedicated ANOVA result object with per-group and total sample-size helpers
- General linear-model power analysis compatible with `pwr.f2.test`
- Dedicated `F2Result` with implied total sample-size helpers
- Regularized incomplete gamma functions
- Central and noncentral chi-square distribution utilities
- Cohen's `w` effect-size helpers for goodness-of-fit and association tests
- Chi-square power analysis compatible with `pwr.chisq.test`
- Dedicated `ChiSquareResult` with total sample-size helper
- Data-first power-curve generation via `StatPower::PowerCurve.generate`
- Immutable `PowerCurvePoint` values for plotting-library-independent output
- Fixture-driven CRAN `pwr` parity validation across all implemented solver families
- Documented numerical tolerance and reference-provenance policy

## 0.1.0.alpha.1 - 2026-09-19

### Added

- Initial gem structure
- RSpec, RuboCop, and Steep configuration
- CI across supported Ruby versions
- Project roadmap
- Mathematical conventions
- Standard normal PDF, CDF, survival function, and quantile utilities
- Deterministic bracketed bisection root solver
- Numerical domain and convergence error types
- CRAN `pwr` compatibility and validation strategy
- Normal-mean power analysis compatible with `pwr.norm.test`
- Conventional Cohen effect-size lookup
- Continuous and integer-required sample-size reporting
- Cohen's h effect-size calculation for proportions
- One-sample proportion power analysis compatible with `pwr.p.test`
- Equal-size two-sample proportion power analysis compatible with `pwr.2p.test`
- Unequal-size two-sample proportion power analysis compatible with `pwr.2p2n.test`
- Dedicated result object for unequal two-group designs
- Regularized incomplete beta special function
- Adaptive Simpson quadrature
- Central Student t PDF, CDF, survival, and quantile utilities
- Noncentral Student t CDF and survival utilities
- One-sample, paired, and equal-size two-sample t-test power analysis compatible with `pwr.t.test`
- Unequal-size two-sample t-test power analysis compatible with `pwr.t2n.test`
- Pearson correlation power analysis compatible with `pwr.r.test`
- Central F PDF, CDF, survival, and quantile utilities
- Noncentral F CDF and survival utilities
