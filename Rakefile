# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "rubocop/rake_task"

RSpec::Core::RakeTask.new(:spec)
RuboCop::RakeTask.new

desc "Validate the RBS signatures in sig/"
task :rbs do
  sh "bundle exec rbs validate"
end

desc "Type check lib/ against the signatures in sig/"
task :steep do
  sh "bundle exec steep check"
end

desc "Run the suite with coverage instrumentation enabled"
task :coverage do
  ENV["COVERAGE"] = "1"
  Rake::Task[:spec].invoke
end

desc "Confirm the library loads from a clean process"
task :load_check do
  sh %(ruby -Ilib -e 'require "stat_power"')
end

desc "Run every check that CI runs"
task verify: %i[spec rubocop rbs steep load_check]

task default: %i[spec rubocop]
