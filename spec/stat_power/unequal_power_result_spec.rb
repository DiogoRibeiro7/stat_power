# frozen_string_literal: true

RSpec.describe StatPower::UnequalPowerResult do
  subject(:result) do
    described_class.new(
      sample_size1: 80.0,
      sample_size2: 245.25,
      power: 0.8,
      effect_size: 0.3,
      alpha: 0.05,
      alternative: :two_sided,
      analysis_method: "example"
    )
  end

  it "reports rounded group sizes independently" do
    expect(result.required_sample_size1).to eq(80)
    expect(result.required_sample_size2).to eq(246)
  end

  it "reports continuous and integer total sample sizes" do
    expect(result.total_sample_size).to eq(325.25)
    expect(result.required_total_sample_size).to eq(326)
  end
end
