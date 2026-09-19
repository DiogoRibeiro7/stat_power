# CRAN pwr parity

`stat_power` uses CRAN `pwr` as its first compatibility and validation target.

The implementation is native Ruby. The project does not translate or copy the
GPL-licensed R source line by line. Public statistical definitions, documented
behaviour, published formulas, and numerical outputs are used as independent
reference points.

## Compatibility target

| CRAN pwr function | stat_power target | Status |
| --- | --- | --- |
| `pwr.norm.test` | `StatPower::NormalMean.solve` | Implemented |
| `cohen.ES` | `StatPower::EffectSize::Conventional.resolve` | Implemented for conventional values |
| `pwr.p.test` | `StatPower::Proportion.one_sample` | Implemented |
| `pwr.2p.test` | `StatPower::Proportion.two_sample` | Implemented |
| `pwr.2p2n.test` | `StatPower::Proportion.two_sample_unequal` | Implemented |
| `pwr.t.test` | `StatPower::TTest.one_sample`, `.paired`, `.two_sample` | Implemented |
| `pwr.t2n.test` | `StatPower::TTest.two_sample_unequal` | Implemented |
| `pwr.anova.test` | balanced one-way ANOVA power | Planned |
| `pwr.r.test` | `StatPower::Correlation.solve` | Implemented |
| `pwr.chisq.test` | chi-square power | Planned |
| `pwr.f2.test` | general linear-model power | Planned |
| `ES.h` | `StatPower::EffectSize::Proportion.cohen_h` | Implemented |
| `ES.w1` | Cohen w for goodness of fit | Planned |
| `ES.w2` | Cohen w for contingency tables | Planned |
| `plot.power.htest` | power-curve data generation | Planned |

## Solver convention

As in `pwr`, a power-analysis family solves one omitted quantity from the
remaining quantities. Ruby uses explicit keyword arguments and `nil` for the
unknown parameter.

For example:

```ruby
StatPower::NormalMean.solve(
  effect_size: 0.5,
  alpha: 0.05,
  power: 0.8
)
```

returns the continuous sample-size solution. Call
`required_sample_size` on the result to obtain the smallest integer not below
that solution.

## Validation policy

Each migrated family should include:

1. formula-level tests where a closed form or independently derived expression
   is available,
2. numerical reference tests against CRAN `pwr`,
3. edge and invalid-domain tests,
4. inverse-problem tests for every parameter the family can solve.

Parity means agreement in the statistical model and numerical result within a
documented tolerance. Ruby naming and object design remain idiomatic rather
than cloning R syntax.
