# frozen_string_literal: true

require "yaml"

RSpec.describe "CRAN pwr parity fixtures" do
  FIXTURE_PATH = File.expand_path("../fixtures/pwr_parity.yml", __dir__)

  CALLS = {
    "normal_mean" => ->(**arguments) { StatPower::NormalMean.solve(**arguments) },
    "proportion_one" => ->(**arguments) { StatPower::Proportion.one_sample(**arguments) },
    "proportion_two" => ->(**arguments) { StatPower::Proportion.two_sample(**arguments) },
    "proportion_unequal" => ->(**arguments) { StatPower::Proportion.two_sample_unequal(**arguments) },
    "t_one" => ->(**arguments) { StatPower::TTest.one_sample(**arguments) },
    "t_paired" => ->(**arguments) { StatPower::TTest.paired(**arguments) },
    "t_two" => ->(**arguments) { StatPower::TTest.two_sample(**arguments) },
    "t_unequal" => ->(**arguments) { StatPower::TTest.two_sample_unequal(**arguments) },
    "correlation" => ->(**arguments) { StatPower::Correlation.solve(**arguments) },
    "anova" => ->(**arguments) { StatPower::Anova.solve(**arguments) },
    "f2" => ->(**arguments) { StatPower::F2.solve(**arguments) },
    "chi_square" => ->(**arguments) { StatPower::ChiSquare.solve(**arguments) }
  }.freeze

  fixture_data = YAML.safe_load_file(FIXTURE_PATH, permitted_classes: [], aliases: false)

  fixture_data.fetch("cases").each do |fixture|
    it "#{fixture.fetch("id")} matches #{fixture.fetch("pwr_function")}" do
      arguments = fixture.fetch("arguments").transform_keys(&:to_sym)
      expected = fixture.fetch("expected")
      result = CALLS.fetch(fixture.fetch("call")).call(**arguments)
      actual = result.public_send(expected.fetch("field"))

      expect(actual).to be_within(expected.fetch("tolerance")).of(expected.fetch("value"))
    end
  end
end
