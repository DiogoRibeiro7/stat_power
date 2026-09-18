# frozen_string_literal: true

RSpec.describe StatPower do
  it "defines a version" do
    expect(StatPower::VERSION).not_to be_nil
  end

  it "provides an immutable result value object" do
    result = StatPower::Result.new(
      sample_size: 64,
      power: 0.8,
      effect_size: 0.5,
      alpha: 0.05
    )

    expect(result.sample_size).to eq(64)
    expect(result.power).to eq(0.8)
  end
end
