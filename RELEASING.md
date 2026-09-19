# Releasing stat_power

This project uses prerelease versions until the public API is ready to stabilize.

## Alpha release checklist

1. Ensure all CI jobs are green on `main`.
2. Confirm `lib/stat_power/version.rb` contains the intended version.
3. Update `CHANGELOG.md` with the release date.
4. Build the gem locally:

   ```bash
   gem build stat_power.gemspec
   ```

5. Inspect the built package:

   ```bash
   gem specification stat_power-*.gem name version files --yaml
   ```

6. Install the built gem into a clean location:

   ```bash
   GEM_HOME="$(mktemp -d)" gem install stat_power-*.gem --no-document
   ```

7. Run a smoke test against the installed package:

   ```bash
   ruby -e 'require "stat_power"; p StatPower::VERSION'
   ```

8. Create the git tag:

   ```bash
   git tag v0.1.0.alpha.1
   git push origin v0.1.0.alpha.1
   ```

9. Publish manually to RubyGems:

   ```bash
   gem push stat_power-0.1.0.alpha.1.gem
   ```

RubyGems MFA is required by the gem metadata, so publishing should remain an
explicit maintainer action rather than an automatic CI side effect.

## After publishing

Verify the public installation path:

```bash
gem install stat_power --prerelease
```

Then confirm:

```bash
ruby -e 'require "stat_power"; puts StatPower::VERSION'
```

The expected output for the first alpha is:

```text
0.1.0.alpha.1
```
