# Releasing stat_power

This project uses prerelease versions until the public API is ready to stabilize.

## RubyGems trusted publishing

RubyGems Trusted Publishing allows GitHub Actions to publish without storing a
long-lived RubyGems API key.

The trusted publisher for `stat_power` must match:

- Gem name: `stat_power`
- Repository owner: `DiogoRibeiro7`
- Repository name: `stat_power`
- Workflow filename: `release.yml`
- Environment: `release`

The workflow is stored at `.github/workflows/release.yml`.

## Alpha release checklist

1. Ensure all CI jobs are green on `main`, and that the local checkout is
   actually at that commit:

   ```bash
   git checkout main
   git pull --ff-only
   bundle exec rake verify
   ```

   Tagging a stale checkout is the most common way this release fails: the
   tag lands on an old commit and the version guard rejects it.

2. Confirm `lib/stat_power/version.rb` contains the intended version.
3. Move the release entries in `CHANGELOG.md` out of `Unreleased`.
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
   ruby -e 'require "stat_power"; puts StatPower::VERSION'
   ```

8. Confirm the RubyGems trusted publisher still matches
   `.github/workflows/release.yml` and the `release` environment.

9. Create and push the release tag. For the current release:

   ```bash
   VERSION=0.1.0.alpha.3
   git checkout main
   git pull --ff-only
   git tag "v${VERSION}"
   git push origin "v${VERSION}"
   ```

Pushing the tag triggers the release workflow. It validates that:

- the tag matches `StatPower::VERSION`
- the tagged commit is contained in `main`
- the test suite passes
- RuboCop passes
- RBS signatures validate
- the gem builds successfully

The workflow requests short-lived RubyGems credentials through OIDC, pushes the
already-built gem artifact with `gem push`, and creates a GitHub Release.
Prerelease versions are marked as prereleases on GitHub automatically.

## Retrying a failed release

If a release tag already exists but the workflow fails before RubyGems accepts
the gem, do not create a new version merely to retry the same artifact.

1. Open **Actions → Release gem**.
2. Choose **Run workflow**.
3. Enter the existing tag, for example `v0.1.0.alpha.3`.
4. Run the workflow from `main`.

The manual dispatch checks out the existing tag and publishes that exact
artifact while using the latest release workflow definition from `main`.

Once a version appears on RubyGems.org, it is immutable and must not be reused.

## After publishing

Verify the public installation path:

```bash
gem install stat_power --prerelease
```

Then confirm:

```bash
ruby -e 'require "stat_power"; puts StatPower::VERSION'
```

For the current release the expected output is:

```text
0.1.0.alpha.3
```

## Failed releases after publication

Once a version exists on RubyGems.org, do not overwrite or reuse that version.
Increment the prerelease version and create a new tag.
