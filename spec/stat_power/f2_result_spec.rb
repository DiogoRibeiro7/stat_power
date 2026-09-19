# frozen_string_literal: true

RSpec.describe StatPower::F2Result do
  subject(:result) do
    described_class.new(
      numerator_df: 5.0,
      denominator_df: 89.0,
      power: 0.8,
      effect_size: 0.15,
      alpha: 0.05,
      analysis_method: "example"
    )
  end

  it "reports the implied total sample size" do
    expect(result.total_sample_size).to eq(95.0)
  end

  it "rounds the implied total sample size upward" do
    fractional = described_class.new(
      numerator_df: 5.0,
      denominator_df: 89.2,
      power: 0.8,
      effect_size: 0.15,
      alpha: 0.05,
      analysis_method: "example"
    )

    expect(fractional.required_total_sample_size).to eq(96)
  end
end
