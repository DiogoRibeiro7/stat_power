# Contributing to stat_power

Thanks for considering a contribution. `stat_power` is a numerical library, so
the bar for changes is correctness first: a contribution that is fast, idiomatic
and well factored is still rejected if its numbers cannot be reproduced.

## Ground rules

- Discuss substantial changes in an issue before opening a pull request.
- Every statistical result must be justified by a published formula or an
  independently generated reference value, never by the output of this library.
- Public API changes during the `0.1.0.alpha.*` series are allowed, but they
  must be recorded in `CHANGELOG.md`.

## Getting set up

```bash
git clone https://github.com/DiogoRibeiro7/stat_power.git
cd stat_power
bin/setup
```

`bin/setup` installs dependencies. `bin/console` opens an IRB session with the
library already loaded.

## The checks that must pass

CI runs these on Ruby 3.2, 3.3 and 3.4. Run them locally before pushing:

```bash
bundle exec rake        # spec + rubocop
bundle exec steep check # type check against sig/
bundle exec rbs validate
```

Or all of them at once:

```bash
bundle exec rake verify
```

### Test coverage

The suite measures line coverage and fails below the threshold configured in
`spec/spec_helper.rb`. Open `coverage/index.html` after a run to see what is
uncovered.

## Adding a statistical method

New power-analysis families follow a fixed shape. Look at
`lib/stat_power/anova.rb` for a complete worked example.

1. **Implement the solver** in `lib/stat_power/`. Exactly one principal
   parameter is left `nil` and solved from the rest; that convention is what
   makes the API predictable across families.
2. **Return a `Data` result object**, not a `Hash`. Results are immutable and
   expose `required_sample_size` where a continuous sample size is solved.
3. **Validate inputs eagerly** and raise `StatPower::DomainError` with a
   message naming the offending parameter. Solver non-convergence raises
   `StatPower::ConvergenceError`.
4. **Declare the public API in `sig/stat_power.rbs`.** Internal helpers may stay
   undeclared; anything a caller can reach may not.
5. **Add reference fixtures** to `spec/fixtures/pwr_parity.yml` and unit specs
   under `spec/stat_power/`.
6. **Document the conventions** you relied on in `docs/mathematical_conventions.md`
   if the method introduces a new one, and update the compatibility matrix in
   `docs/pwr_parity.md`.
7. **Add a `CHANGELOG.md` entry** under `## Unreleased`.

## Numerical reference values

Parity fixtures are checked against CRAN `pwr`. When you add one, record how it
was produced so a reviewer can regenerate it:

```r
library(pwr)
pwr.anova.test(k = 4, n = 20, f = 0.28, sig.level = 0.05)
```

Paste the R snippet and its output into the pull request. Tolerances are not
negotiable per-test; they follow the policy in `docs/validation.md`. If a value
needs a looser tolerance than the policy allows, that is a finding about the
implementation, not about the test.

## Commit and pull request style

- Write commit subjects in the imperative mood: `Add pwr.chisq.test parity`.
- Keep a pull request to one logical change. A new distribution and a new
  solver that uses it are two pull requests.
- Pull requests are squash merged, so the pull request title becomes the commit
  subject on `main`.

## Reporting a numerical discrepancy

If `stat_power` disagrees with `pwr`, R, SAS, G*Power or a textbook, open an
issue using the **Numerical discrepancy** template. Include the exact inputs,
both outputs, and the reference tool's version. A disagreement in the sixth
decimal place is still worth reporting; it usually points at a convergence
tolerance rather than a wrong formula.
