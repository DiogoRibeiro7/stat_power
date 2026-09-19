# Changelog

All notable changes to this project will be documented in this file.

## Unreleased

### Added

- Balanced one-way ANOVA power analysis compatible with `pwr.anova.test`
- Dedicated ANOVA result object with per-group and total sample-size helpers

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
