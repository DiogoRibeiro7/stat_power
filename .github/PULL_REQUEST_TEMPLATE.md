## Summary

<!-- What does this change and why. One logical change per pull request. -->

## Type of change

- [ ] New power-analysis family or effect size
- [ ] Numerical correctness fix
- [ ] API change (allowed during `0.1.0.alpha.*`, must be in the changelog)
- [ ] Documentation
- [ ] Tooling, CI or release process

## Numerical validation

<!--
Required for any change that alters a computed value. Paste the reference
snippet and its output so a reviewer can regenerate it. Delete this section
only for documentation and tooling changes.
-->

```r
library(pwr)
# reference call and output
```

- [ ] Reference values were generated independently, not from `stat_power`
- [ ] Fixtures added to `spec/fixtures/pwr_parity.yml`
- [ ] Tolerances follow `docs/validation.md`

## Checklist

- [ ] `bundle exec rake verify` passes locally
- [ ] Public API additions are declared in `sig/stat_power.rbs`
- [ ] `CHANGELOG.md` updated under `## Unreleased`
- [ ] `docs/pwr_parity.md` updated if compatibility coverage changed
