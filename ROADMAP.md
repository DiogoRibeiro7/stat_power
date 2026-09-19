# Roadmap

## 0.1.x — CRAN pwr parity and numerical foundations

### Foundations

- [x] Core result and error types
- [x] Standard normal distribution utilities
- [x] Root-finding infrastructure
- [x] Conventional Cohen effect-size lookup
- [x] Normal mean power analysis equivalent to `pwr.norm.test`
- [x] Student t distribution utilities
- [x] Noncentral t distribution utilities
- [ ] Chi-square and noncentral chi-square utilities
- [ ] F and noncentral F utilities

### pwr compatibility

- [x] `pwr.norm.test`
- [x] `pwr.p.test`
- [x] `pwr.2p.test`
- [x] `pwr.2p2n.test`
- [ ] `pwr.t.test`
- [ ] `pwr.t2n.test`
- [ ] `pwr.anova.test`
- [ ] `pwr.r.test`
- [ ] `pwr.chisq.test`
- [ ] `pwr.f2.test`
- [x] `ES.h`
- [ ] `ES.w1`
- [ ] `ES.w2`
- [ ] power-curve data equivalent to `plot.power.htest`

Each migrated family must support the inverse problems exposed by the reference
method and include numerical parity tests.

## 0.2.x — Validation and usability

- Automated parity fixtures generated from R `pwr`
- Published Cohen examples
- Cross-validation against statsmodels where applicable
- Documented numerical tolerance policy
- Stable result objects
- User-facing method documentation
- Benchmarks

## 0.3.x — Beyond pwr: regression and richer designs

- Additional regression power models
- Partial and semi-partial correlation
- Unequal allocation helpers
- Attrition and dropout adjustments

## 0.4.x — Equivalence and non-inferiority

- TOST
- One-sided non-inferiority tests
- Equivalence for means and proportions

## 0.5.x — Repeated and clustered designs

- Repeated-measures designs
- Mixed designs
- Cluster-randomised trials
- Design effects
- Intra-cluster correlation
- Unequal cluster sizes

## 0.6.x — Precision-based design

- Confidence-interval width targets
- Mean, proportion, and difference precision

## 0.7.x — Simulation-based power

- User-defined simulation models
- Monte Carlo uncertainty estimates
- Reproducible random seeds
- Parallel execution interface

## 0.8.x — pwrss-inspired extensions

- Broader sample-size methods
- Minimum detectable effects
- Additional test families selected from mature reference implementations

## 0.9.x — API hardening

- Complete validation matrix
- Performance review
- Documentation audit
- API stability review

## 1.0.0

- Stable public API
- Complete user and mathematical documentation
- Reproducible validation suite
- RubyGems release
