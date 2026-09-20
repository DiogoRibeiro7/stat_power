# frozen_string_literal: true

RSpec.describe StatPower::ChiSquare do
  describe ".solve" do
    it "matches Cohen exercise 7.1" do
      result = described_class.solve(
        degrees_of_freedom: 3,
        effect_size: 0.289,
        sample_size: 100,
        alpha: 0.05
      )

      expect(result.power).to be_within(1e-10).of(0.6750776570037209)
    end

    it "matches Cohen exercise 7.3" do
      result = described_class.solve(
        degrees_of_freedom: 2,
        effect_size: 0.346,
        sample_size: 140,
        alpha: 0.01
      )

      expect(result.power).to be_within(1e-10).of(0.88540528724145)
    end

    it "solves total sample size for Cohen exercise 7.8" do
      result = described_class.solve(
        degrees_of_freedom: 20,
        effect_size: 0.1,
        alpha: 0.05,
        power: 0.8
      )

      expect(result.sample_size).to be_within(1e-5).of(2096.079183370389)
      expect(result.required_sample_size).to eq(2097)
    end

    it "solves effect size for target power" do
      result = described_class.solve(
        degrees_of_freedom: 3,
        sample_size: 100,
        alpha: 0.05,
        power: 0.8
      )

      expect(result.effect_size).to be_within(1e-7).of(0.3301902980121201)
    end

    it "solves alpha for target power" do
      result = described_class.solve(
        degrees_of_freedom: 3,
        effect_size: 0.289,
        sample_size: 100,
        alpha: nil,
        power: 0.8
      )

      expect(result.alpha).to be_within(1e-7).of(0.11517470888572412)
    end

    it "accepts conventional Cohen w effect sizes" do
      named = described_class.solve(
        degrees_of_freedom: 3,
        effect_size: :medium,
        sample_size: 100,
        alpha: 0.05
      )
      numeric = described_class.solve(
        degrees_of_freedom: 3,
        effect_size: 0.3,
        sample_size: 100,
        alpha: 0.05
      )

      expect(named.power).to be_within(1e-12).of(numeric.power)
    end

    it "requires exactly one unknown parameter" do
      expect do
        described_class.solve(
          degrees_of_freedom: 3,
          effect_size: 0.3,
          sample_size: 100,
          alpha: 0.05,
          power: 0.8
        )
      end.to raise_error(StatPower::DomainError, /exactly one/)
    end

    it "requires degrees of freedom" do
      expect do
        described_class.solve(
          degrees_of_freedom: 0,
          effect_size: 0.3,
          sample_size: 100,
          alpha: 0.05
        )
      end.to raise_error(StatPower::DomainError, /positive/)
    end
  end
end
