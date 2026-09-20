# frozen_string_literal: true

RSpec.describe StatPower::ChiSquareResult do
  subject(:result) do
    described_class.new(
      degrees_of_freedom: 3.0,
      sample_size: 99.2,
      power: 0.8,
      effect_size: 0.3,
      alpha: 0.05,
      analysis_method: "example"
    )
  end

  it "rounds total sample size upward" do
    expect(result.required_sample_size).to eq(100)
  end
end
