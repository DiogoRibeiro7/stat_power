# frozen_string_literal: true

RSpec.describe StatPower::NormalMean do
  describe ".solve" do
    it "computes two-sided power" do
      result = described_class.solve(
        effect_size: 0.5,
        sample_size: 30,
        alpha: 0.05
      )

      expect(result.power).to be_within(1e-8).of(0.7819079987)
    end

    it "computes greater-tail power" do
      result = described_class.solve(
        effect_size: 0.5,
        sample_size: 30,
        alpha: 0.05,
        alternative: :greater
      )

      expect(result.power).to be_within(1e-8).of(0.8629696901)
    end

    it "solves sample size for target power" do
      result = described_class.solve(
        effect_size: 0.5,
        alpha: 0.05,
        power: 0.8
      )

      expect(result.sample_size).to be_within(1e-6).of(31.39544204)
      expect(result.required_sample_size).to eq(32)
    end

    it "solves effect size for target power" do
      result = described_class.solve(
        sample_size: 30,
        alpha: 0.05,
        power: 0.8
      )

      expect(result.effect_size).to be_within(1e-6).of(0.51149651)
    end

    it "solves alpha for target power" do
      result = described_class.solve(
        effect_size: 0.5,
        sample_size: 30,
        alpha: nil,
        power: 0.8
      )

      expect(result.alpha).to be_within(1e-6).of(0.05782821)
    end

    it "accepts pwr-style two.sided alternatives" do
      result = described_class.solve(
        effect_size: 0.5,
        sample_size: 30,
        alpha: 0.05,
        alternative: "two.sided"
      )

      expect(result.alternative).to eq(:two_sided)
    end

    it "accepts conventional effect-size names" do
      named = described_class.solve(
        effect_size: :medium,
        sample_size: 30,
        alpha: 0.05
      )

      numeric = described_class.solve(
        effect_size: 0.5,
        sample_size: 30,
        alpha: 0.05
      )

      expect(named.power).to be_within(1e-12).of(numeric.power)
    end

    it "uses the magnitude of the effect for a two-sided test" do
      positive = described_class.solve(
        effect_size: 0.5,
        sample_size: 30,
        alpha: 0.05
      )
      negative = described_class.solve(
        effect_size: -0.5,
        sample_size: 30,
        alpha: 0.05
      )

      expect(negative.power).to be_within(1e-12).of(positive.power)
    end

    it "requires exactly one unknown parameter" do
      expect do
        described_class.solve(
          effect_size: 0.5,
          sample_size: 30,
          alpha: 0.05,
          power: 0.8
        )
      end.to raise_error(StatPower::DomainError, /exactly one/)
    end
  end
end
