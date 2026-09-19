# frozen_string_literal: true

require_relative "lib/stat_power/version"

Gem::Specification.new do |spec|
  spec.name = "stat_power"
  spec.version = StatPower::VERSION
  spec.authors = ["Diogo Ribeiro"]
  spec.summary = "Statistical power analysis and sample-size determination for Ruby"
  spec.description = [
    "Native Ruby tools for statistical power analysis,",
    "sample-size determination, effect-size calculations,",
    "and inverse power problems."
  ].join(" ")
  spec.homepage = "https://github.com/DiogoRibeiro7/stat_power"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2"

  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata["documentation_uri"] = "#{spec.homepage}#readme"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = Dir[
    "lib/**/*",
    "sig/**/*",
    "docs/**/*",
    "README.md",
    "ROADMAP.md",
    "CHANGELOG.md",
    "RELEASING.md",
    "LICENSE"
  ]
  spec.require_paths = ["lib"]
end
