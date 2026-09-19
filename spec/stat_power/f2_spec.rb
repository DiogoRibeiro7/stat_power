# frozen_string_literal: true

RSpec.describe StatPower::F2 do
  describe ".solve" do
    it "matches a Cohen-style reference case" do
      result = described_class.solve(
        numerator_df: 5,
        denominator_df: 89,
        effect_size: 1.0 / 9.0,
        alpha: 0.05
      )

      expect(result.power).to be_within(1e-8).of(0.6735857708)
      expect(result.total_sample_size).to eq(95.0)
    end

    it "solves denominator degrees of freedom for target power" do
      result = described_class.solve(
        numerator_df: 5,
        denominator_df: nil,
        effect_size: 1.0 / 9.0,
        alpha: 0.05,
        power: 0.8
      )

      expect(result.denominator_df).to be_within(1e-5).of(115.1043085)
      expect(result.required_total_sample_size).to eq(122)
    end

    it "accepts conventional Cohen f2 effect sizes" do
      named = described_class.solve(
        numerator_df: 5,
        denominator_df: 89,
        effect_size: :medium,
        alpha: 0.05
      )
      numeric = described_class.solve(
        numerator_df: 5,
        denominator_df: 89,
        effect_size: 0.15,
        alpha: 0.05
      )

      expect(named.power).to be_within(1e-12).of(numeric.power)
    end

    it "solves effect size for target power" do
      reference = described_class.solve(
        numerator_df: 5,
        denominator_df: 89,
        effect_size: 0.15,
        alpha: 0.05
      )

      solved = described_class.solve(
        numerator_df: 5,
        denominator_df: 89,
        effect_size: nil,
        alpha: 0.05,
        power: reference.power
      )

      expect(solved.effect_size).to be_within(1e-6).of(0.15)
    end

    it "solves alpha for target power" do
      reference = described_class.solve(
        numerator_df: 5,
        denominator_df: 89,
        effect_size: 0.15,
        alpha: 0.05
      )

      solved = described_class.solve(
        numerator_df: 5,
        denominator_df: 89,
        effect_size: 0.15,
        alpha: nil,
        power: reference.power
      )

      expect(solved.alpha).to be_within(1e-6).of(0.05)
    end

    it "round-trips numerator degrees of freedom" do
      reference = described_class.solve(
        numerator_df: 5,
        denominator_df: 89,
        effect_size: 0.15,
        alpha: 0.05
      )

      solved = described_class.solve(
        numerator_df: nil,
        denominator_df: 89,
        effect_size: 0.15,
        alpha: 0.05,
        power: reference.power
      )

      expect(solved.numerator_df).to be_within(1e-5).of(5.0)
    end

    it "requires exactly one unknown parameter" do
      expect do
        described_class.solve(
          numerator_df: 5,
          denominator_df: 89,
          effect_size: 0.15,
          alpha: 0.05,
          power: 0.8
        )
      end.to raise_error(StatPower::DomainError, /exactly one/)
    end
  end
end
