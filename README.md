# stat_power

Native Ruby statistical power analysis and sample-size determination.

> **Alpha release:** `stat_power` is under active development. The public API
> may change before the first stable release. Pin an exact version in production
> or research environments where reproducibility matters.

## Installation

The current release is a prerelease:

```bash
gem install stat_power --prerelease
```

or pin the exact alpha:

```bash
gem install stat_power -v 0.1.0.alpha.1
```

With Bundler:

```ruby
gem "stat_power", "0.1.0.alpha.1"
```

## Status

The first compatibility target is the established CRAN `pwr` package. The
implementation is native Ruby and is validated against published formulas and
reference numerical results rather than being a line-by-line source port.

Implemented compatibility currently includes:

- `pwr.norm.test`
- `pwr.p.test`
- `pwr.2p.test`
- `pwr.2p2n.test`
- `pwr.t.test`
- `pwr.t2n.test`
- `pwr.r.test`

The library also contains the numerical distribution machinery required for
further power methods, including central/noncentral t and F distributions.

See [docs/pwr_parity.md](docs/pwr_parity.md) for the full compatibility matrix.

## Example

```ruby
require "stat_power"

result = StatPower::TTest.two_sample(
  effect_size: 0.5,
  alpha: 0.05,
  power: 0.8
)

result.sample_size
# continuous observations required per group

result.required_sample_size
# smallest whole-number sample size per group
```

Power-analysis methods follow a common convention: one principal parameter is
omitted and solved from the remaining values.

For example, achieved power:

```ruby
result = StatPower::Correlation.solve(
  correlation: 0.3,
  sample_size: 50,
  alpha: 0.05
)

result.power
```

## Goals

- parity with the statistical families provided by CRAN `pwr`
- idiomatic Ruby APIs
- sample-size determination and achieved-power calculations
- inverse power problems
- effect-size utilities
- explicit assumptions and numerical tolerances
- independently reproducible numerical validation
- later extensions beyond `pwr`

## Alpha stability policy

During the `0.1.0.alpha.*` series:

- numerical correctness and validation take priority over API stability
- method and result names may change when inconsistencies are found
- every implemented statistical family should include independent reference tests
- new CRAN `pwr` parity targets may be added between alpha releases

The transition to beta will indicate that the public API is approaching a
freeze candidate.

## Development

Install dependencies:

```bash
bundle install
```

Run the test suite:

```bash
bundle exec rspec
```

Run lint and signature validation:

```bash
bundle exec rubocop
bundle exec rbs validate
```

Validate that the library loads:

```bash
ruby -Ilib -e 'require "stat_power"'
```

Build the gem locally:

```bash
gem build stat_power.gemspec
```

## Mathematical conventions

See [docs/mathematical_conventions.md](docs/mathematical_conventions.md).

For numerical reference fixtures and tolerance rules, see
[docs/validation.md](docs/validation.md).

## Roadmap

See [ROADMAP.md](ROADMAP.md).

## Releasing

See [RELEASING.md](RELEASING.md).

## License

MIT.
