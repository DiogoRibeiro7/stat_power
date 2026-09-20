# frozen_string_literal: true

# Coverage instrumentation roughly doubles the runtime of the suite, so it is
# opt-in rather than always on. CI measures it in a dedicated job; run
# `COVERAGE=1 bundle exec rspec` to reproduce that measurement locally.
if ENV["COVERAGE"]
  require "simplecov"

  SimpleCov.start do
    enable_coverage :branch

    add_filter "/spec/"

    add_group "Distributions", "lib/stat_power/distributions"
    add_group "Special functions", "lib/stat_power/special_functions"
    add_group "Effect sizes", "lib/stat_power/effect_size"
    add_group "Solvers", "lib/stat_power/solvers"
    add_group "Integration", "lib/stat_power/integration"

    # These thresholds are a ratchet, not a target. They are set just below the
    # current measurement so that coverage cannot regress; raise them whenever
    # the suite clears the next whole percentage point.
    minimum_coverage line: 92, branch: 76
  end
end

require "stat_power"

RSpec.configure do |config|
  config.disable_monkey_patching!
  config.order = :random

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.filter_run_when_matching :focus
end
