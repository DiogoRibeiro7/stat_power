# frozen_string_literal: true

RSpec.describe StatPower::Proportion do
  describe ".one_sample" do
    it "matches the CRAN pwr vignette reference" do
      result = described_class.one_sample(
        effect_size: 0.5,
        sample_size: 20,
        alpha: 0.05
      )

      expect(result.power).to be_within(1e-7).of(0.6087795)
    end

    it "matches Cohen exercise 6.5 for h = 0.2 and n = 60" do
      result = described_class.one_sample(
        effect_size: 0.2,
        sample_size: 60,
        alpha: 0.05
      )

      expect(result.power).to be_within(1e-8).of(0.3408451241)
    end

    it "solves sample size for a target power" do
      result = described_class.one_sample(
        effect_size: 0.2,
        alpha: 0.05,
        power: 0.95
      )

      expect(result.sample_size).to be_within(1e-5).of(324.8677274)
      expect(result.required_sample_size).to eq(325)
    end

    it "round-trips every inverse parameter" do
      reference = described_class.one_sample(
        effect_size: 0.3,
        sample_size: 80,
        alpha: 0.05
      )

      effect = described_class.one_sample(
        sample_size: 80,
        alpha: 0.05,
        power: reference.power
      )
      sample = described_class.one_sample(
        effect_size: 0.3,
        alpha: 0.05,
        power: reference.power
      )
      alpha = described_class.one_sample(
        effect_size: 0.3,
        sample_size: 80,
        alpha: nil,
        power: reference.power
      )

      expect(effect.effect_size).to be_within(1e-7).of(0.3)
      expect(sample.sample_size).to be_within(1e-5).of(80.0)
      expect(alpha.alpha).to be_within(1e-7).of(0.05)
    end

    it "accepts conventional effect-size names" do
      result = described_class.one_sample(
        effect_size: :medium,
        sample_size: 20,
        alpha: 0.05
      )

      expect(result.power).to be_within(1e-7).of(0.6087795)
    end
  end

  describe ".two_sample" do
    it "matches the one-sided Cohen exercise reference" do
      result = described_class.two_sample(
        effect_size: 0.3,
        sample_size: 80,
        alpha: 0.05,
        alternative: :greater
      )

      expect(result.power).to be_within(1e-8).of(0.5996777045)
    end

    it "matches the published pwr sample-size example" do
      effect = StatPower::EffectSize::Proportion.cohen_h(p1: 0.38, p2: 0.30)

      result = described_class.two_sample(
        effect_size: effect,
        alpha: 0.05,
        power: 0.9
      )

      expect(result.sample_size).to be_within(1e-4).of(734.4749)
      expect(result.required_sample_size).to eq(735)
    end

    it "treats sample size as observations per group" do
      result = described_class.two_sample(
        effect_size: 0.5,
        sample_size: 40,
        alpha: 0.05
      )
      one_sample = described_class.one_sample(
        effect_size: 0.5,
        sample_size: 20,
        alpha: 0.05
      )

      expect(result.power).to be_within(1e-12).of(one_sample.power)
    end

    it "round-trips inverse parameters" do
      reference = described_class.two_sample(
        effect_size: 0.25,
        sample_size: 100,
        alpha: 0.05
      )

      effect = described_class.two_sample(
        sample_size: 100,
        alpha: 0.05,
        power: reference.power
      )
      alpha = described_class.two_sample(
        effect_size: 0.25,
        sample_size: 100,
        alpha: nil,
        power: reference.power
      )

      expect(effect.effect_size).to be_within(1e-7).of(0.25)
      expect(alpha.alpha).to be_within(1e-7).of(0.05)
    end
  end

  it "requires exactly one unknown parameter" do
    expect do
      described_class.one_sample(
        effect_size: 0.2,
        sample_size: 60,
        alpha: 0.05,
        power: 0.8
      )
    end.to raise_error(StatPower::DomainError, /exactly one/)
  end
end
