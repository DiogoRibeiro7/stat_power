# stat_power

Statistical power analysis, sample-size determination, and effect-size utilities for Ruby.

## Status

Early development. The public API is not yet stable.

## Goals

`stat_power` aims to provide mathematically explicit and well-tested power-analysis tools for Ruby, with particular emphasis on:

- sample-size determination,
- achieved-power calculations,
- effect-size utilities,
- inverse power problems,
- reproducible numerical validation.

The project avoids hiding statistical assumptions behind opaque defaults. Test direction, effect-size conventions, allocation assumptions, and numerical tolerances should be explicit.

## Planned API

```ruby
require "stat_power"

result = StatPower::TTest.two_sample(
  effect_size: 0.5,
  alpha: 0.05,
  power: 0.8
)

result.sample_size
# => 64
```

The same test family should eventually support inverse problems, for example solving for power or effect size when sample size is known.

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

The project's statistical and numerical conventions are documented in [docs/mathematical_conventions.md](docs/mathematical_conventions.md).

## Roadmap

See [ROADMAP.md](ROADMAP.md).

## License

MIT.
