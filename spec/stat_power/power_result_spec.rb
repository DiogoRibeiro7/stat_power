# frozen_string_literal: true

RSpec.describe StatPower::PowerResult do
  it "rounds a continuous sample-size solution upward" do
    result = described_class.new(
      sample_size: 31.395,
      power: 0.8,
      effect_size: 0.5,
      alpha: 0.05,
      alternative: :two_sided,
      method: "example"
    )

    expect(result.required_sample_size).to eq(32)
  end
end
