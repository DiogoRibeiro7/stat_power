# frozen_string_literal: true

RSpec.describe StatPower::AnovaResult do
  subject(:result) do
    described_class.new(
      groups: 3.2,
      sample_size: 20.4,
      power: 0.8,
      effect_size: 0.25,
      alpha: 0.05,
      analysis_method: "example"
    )
  end

  it "rounds groups and per-group sample size upward" do
    expect(result.required_groups).to eq(4)
    expect(result.required_sample_size).to eq(21)
  end

  it "reports continuous and practical total sample sizes" do
    expect(result.total_sample_size).to be_within(1e-12).of(65.28)
    expect(result.required_total_sample_size).to eq(84)
  end
end
