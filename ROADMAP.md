# Roadmap to 1.0.0

This document describes what `stat_power` commits to at 1.0.0, what still
stands between the current release and that commitment, and what is
deliberately out of scope.

It is a statement of intent, not a schedule. Milestones are ordered by
dependency rather than by date.

## What 1.0.0 means

Versions below 1.0.0 are working material. The public API can change in any
release, and it has. 1.0.0 is the point at which that stops.

From 1.0.0 the project follows semantic versioning, and the following are
covered by that guarantee:

- **Module and method names** reachable from `require "stat_power"`.
- **Keyword argument names** on every solver, and which combinations are
  accepted.
- **Result object types**, their members, and their helper methods.
- **The error taxonomy** — which exception class is raised for which category
  of failure.
- **The solve-for-the-omitted-parameter convention**: exactly one principal
  parameter is left `nil` and computed from the rest.

Two things are explicitly *not* frozen by the version number:

- **Exact floating-point output.** Numerical methods may be replaced by more
  accurate ones in a minor release. What is guaranteed is agreement with the
  documented reference within the tolerance in
  [docs/validation.md](docs/validation.md). A change that moves a result
  further from the reference is a bug in any version.
- **Private internals.** Anything under `StatPower::Distributions`,
  `StatPower::SpecialFunctions`, `StatPower::Integration` and
  `StatPower::Solvers` is reachable and documented, but it exists to serve the
  power-analysis layer. It is covered by the stability guarantee only where
  [docs/mathematical_conventions.md](docs/mathematical_conventions.md) says so.

### Supported Ruby versions

1.0.0 will support the Ruby versions under active upstream maintenance at the
time of release, currently 3.2 and above. Dropping a Ruby version is a major
release; adding one is not.

## Where the project is today

The CRAN `pwr` compatibility surface is complete. Every family in
[docs/pwr_parity.md](docs/pwr_parity.md) is implemented, validated against
fixture references, and exercised for its inverse problems.

What is not yet true:

- The public API has never been reviewed as a whole. It grew one family at a
  time, and it shows — see the blockers below.
- Coverage is a ratchet rather than a standard. It sits in the low nineties
  for lines and the mid seventies for branches.
- There is no user-facing documentation beyond the README and the two
  mathematical documents.

That is the honest distance to 1.0.0.

## Release ladder

| Milestone | Theme | Status |
| --- | --- | --- |
| 0.1.x | CRAN `pwr` parity and numerical foundations | Complete |
| 0.2.x | Validation, result-object consistency, documentation | In progress |
| 0.3.x | Regression and richer designs | Planned |
| 0.4.x | Equivalence and non-inferiority | Planned |
| 0.5.x | Repeated and clustered designs | Planned |
| 0.6.x | Precision-based design | Planned |
| 0.7.x | Simulation-based power | Planned |
| 0.8.x | Extensions from mature reference implementations | Planned |
| 0.9.x | API freeze candidate | Planned |
| 1.0.0 | Stable public API | — |

Milestones 0.3.x through 0.8.x add statistical coverage. **None of them is a
prerequisite for 1.0.0.** A stable API over a smaller surface is more useful
than an unstable API over a larger one. If the API blockers below are cleared
first, 1.0.0 ships and those milestones become 1.x features.

### 0.3.x — Regression and richer designs

- Additional regression power models
- Partial and semi-partial correlation
- Unequal allocation helpers
- Attrition and dropout adjustments

### 0.4.x — Equivalence and non-inferiority

- Two one-sided tests (TOST)
- One-sided non-inferiority tests
- Equivalence for means and proportions

### 0.5.x — Repeated and clustered designs

- Repeated-measures and mixed designs
- Cluster-randomised trials, design effects, intra-cluster correlation
- Unequal cluster sizes

### 0.6.x — Precision-based design

- Confidence-interval width targets
- Mean, proportion and difference precision

### 0.7.x — Simulation-based power

- User-defined simulation models
- Monte Carlo uncertainty estimates
- Reproducible random seeds
- Parallel execution interface

### 0.8.x — Extensions from mature reference implementations

- Broader sample-size methods
- Minimum detectable effects
- Additional test families selected from established references

## Blockers for 1.0.0

Each of these becomes permanent the moment the version number says the API is
stable.

### A. The result objects need a single design

Six `Data` types are returned by the solvers, and they disagree with each
other in ways that make it impossible to handle a result generically.

- **Member names diverge.** `sample_size` on most, `sample_size1` and
  `sample_size2` on `UnequalPowerResult`, `numerator_df` and `denominator_df`
  on `F2Result`.
- **Helper methods are inconsistent.** `required_sample_size` exists on
  `PowerResult`, `AnovaResult` and `ChiSquareResult`; `UnequalPowerResult` has
  `required_sample_size1` and `required_sample_size2` instead; `F2Result` has
  neither, only `total_sample_size`.
- **`alternative` is present on some results and absent on others.** That is
  defensible, since ANOVA and chi-square tests are inherently one-sided, but it
  is undocumented, so callers cannot know which results carry it.
- **No shared interface.** There is no common module, no documented `to_h`
  contract, and no way to ask a result what it is without checking its class.

Decide the design once, apply it to every family, and document which members
every result is guaranteed to carry.

### B. Remove `StatPower::Result`

`lib/stat_power/result.rb` defines `StatPower::Result`. It is required from the
main entry point, declared in `sig/stat_power.rbs`, and constructed in exactly
one place: its own test in `spec/stat_power_spec.rb`. No solver returns it. It
is scaffolding from the first commit.

It must go before 1.0.0. Afterwards, removing it is a breaking change, and it
becomes permanent.

### C. Validation must be complete and independently reproducible

The fixture suite covers every implemented family. Reaching 1.0.0 needs:

- Every fixture to record the reference snippet that produced it, so a third
  party can regenerate the expected values without trusting this project.
- Cross-validation against at least one reference besides CRAN `pwr` —
  statsmodels or G\*Power — for families where an independent implementation
  exists. Agreeing with a single source is not validation.
- Published Cohen (1988) worked examples as fixtures in their own right.
- Branch coverage raised to a defensible level and held there. Uncovered
  branches in a numerical library are untested edge conditions, not stylistic
  debt.

### D. Documentation

- A user guide covering each family: what it models, which parameters it
  solves, what its assumptions are, and a worked example.
- Assumptions stated in prose per solver, not only in code. Someone making a
  sample-size decision needs to know when a method does not apply to them.
- Generated API documentation published somewhere durable.
- `docs/mathematical_conventions.md` extended to state which internals are
  covered by the stability guarantee and which are not.

### E. Behavioural guarantees worth asserting

These are currently true by construction but untested, which makes them
accidents rather than guarantees:

- **Thread safety.** The library holds no mutable global state and every solver
  is a pure function of its arguments. Assert it with a test so it stays true.
- **Immutability.** Result objects are `Data`, so they are frozen. Document it
  as a guarantee rather than an implementation detail.
- **No runtime dependencies.** Keep it that way. It is a significant part of
  why this gem is easy to adopt.

### F. Process

- A performance baseline and benchmarks, so a later accuracy improvement can be
  weighed against its cost. The suite is slower than a pure-mathematics library
  should be.
- A release path that does not depend on the state of a local checkout.

## Definition of done

1.0.0 ships when all of the following hold:

- [ ] Result objects share a documented, consistent design
- [ ] `StatPower::Result` removed
- [ ] Every fixture records reproducible reference provenance
- [ ] At least one non-`pwr` cross-validation source per family where one exists
- [ ] Branch coverage at a defensible level and enforced
- [ ] User guide covering every implemented family
- [ ] Assumptions documented per solver
- [ ] Thread safety and immutability asserted by tests
- [ ] Performance baseline recorded
- [ ] A full release-candidate cycle with no API changes

The last item is the real gate. If an API change is still being made, the API
is not stable, whatever the rest of the checklist says.

## Path through 0.9.x

0.9.x is the freeze candidate series. Its purpose is to be wrong in public
before the guarantee applies.

1. Land the breaking API changes from blockers A and B. They are breaking,
   which is precisely why they happen before 1.0.0.
2. Release `0.9.0` and ask for API feedback explicitly.
3. Hold the API still. Any change restarts the clock.
4. Release `1.0.0.rc.1` once a full cycle passes with no API change.
5. Release `1.0.0`.

## Non-goals

Stated so they are not mistaken for omissions.

- **Not a port of CRAN `pwr`.** `pwr` is the first compatibility and validation
  target. The API is idiomatic Ruby and will diverge where R's conventions do
  not suit it.
- **Not a statistics framework.** No model fitting, no hypothesis testing on
  data, no plotting. Power analysis and sample-size determination only.
  `PowerCurve` generates data for plotting; rendering belongs to the caller.
- **No native extensions.** Pure Ruby, no compilation step, no runtime
  dependencies. This constrains performance, and that trade is accepted.
- **Not a replacement for statistical judgement.** The library computes what it
  is asked to compute. Whether a design is appropriate is the researcher's
  question, and the documentation should help with it rather than obscure it.

## Contributing to a milestone

New statistical families follow the structure in
[CONTRIBUTING.md](CONTRIBUTING.md).

Work that clears a 1.0.0 blocker is more valuable than work that adds a family,
because the blockers gate the release and the families do not.
