# stat_power

Native Ruby statistical power analysis and sample-size determination.

## Status

Early development. The public API is not yet stable.

The first compatibility target is the established CRAN `pwr` package. The
implementation is native Ruby and is validated against published formulas and
reference numerical results rather than being a line-by-line source port.

## Example

```ruby
require "stat_power"

result = StatPower::NormalMean.solve(
  effect_size: 0.5,
  alpha: 0.05,
  power: 0.8
)

result.sample_size
# => approximately 31.395

result.required_sample_size
# => 32
```

As with CRAN `pwr`, one of the main analysis parameters is omitted and solved
from the others.

## Goals

- parity with the statistical families provided by CRAN `pwr`,
- idiomatic Ruby APIs,
- sample-size determination and achieved-power calculations,
- inverse power problems,
- effect-size utilities,
- explicit assumptions and numerical tolerances,
- independently reproducible numerical validation,
- later extensions beyond `pwr`.

See [docs/pwr_parity.md](docs/pwr_parity.md) for the compatibility matrix.

## Development

Install dependencies:

```bash
bundle install
```

Run the test suite:

```bash
bundle exec rspec
```

Run static checks:

```bash
bundle exec rubocop
bundle exec steep check
```

## Mathematical conventions

See [docs/mathematical_conventions.md](docs/mathematical_conventions.md).

## Roadmap

See [ROADMAP.md](ROADMAP.md).

## License

MIT.
