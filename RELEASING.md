# Releasing stat_power

This project uses prerelease versions until the public API is ready to stabilize.

## One-time RubyGems trusted publisher setup

RubyGems Trusted Publishing allows GitHub Actions to publish without storing a
long-lived RubyGems API key.

For the first release of `stat_power`, create a **pending trusted publisher**
from the RubyGems.org account that should own the gem, using:

- Gem name: `stat_power`
- Repository owner: `DiogoRibeiro7`
- Repository name: `stat_power`
- Workflow filename: `release.yml`
- Environment: `release`

The workflow is stored at `.github/workflows/release.yml`.

After the first successful publication, the pending publisher becomes the
trusted publisher for the gem.

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

8. Confirm the RubyGems pending/trusted publisher is configured for
   `.github/workflows/release.yml` and the `release` environment.

9. Create and push the release tag. The tag must match the version exactly:

   ```bash
   git checkout main
   git pull --ff-only
   git tag v0.1.0.alpha.1
   git push origin v0.1.0.alpha.1
   ```

Pushing the tag triggers the release workflow. It validates that:

- the tag matches `StatPower::VERSION`
- the tagged commit is contained in `main`
- the test suite passes
- RuboCop passes
- RBS signatures validate
- the gem builds successfully

The workflow then publishes to RubyGems using OIDC Trusted Publishing and
creates a GitHub Release. Prerelease versions are marked as prereleases on
GitHub automatically.

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

## Failed releases

If the workflow fails before the RubyGems publishing step, fix the problem and
move the release tag only if the version has not been published.

Once a version exists on RubyGems.org, do not overwrite or reuse that version.
Increment the prerelease version, for example from `0.1.0.alpha.1` to
`0.1.0.alpha.2`, and create a new tag.
