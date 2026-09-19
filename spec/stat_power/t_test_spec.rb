# frozen_string_literal: true

RSpec.describe StatPower::TTest do
  describe ".one_sample" do
    it "matches Cohen exercise 2.5" do
      result = described_class.one_sample(
        effect_size: 0.2,
        sample_size: 60,
        alpha: 0.10
      )

      expect(result.power).to be_within(1e-7).of(0.4555817641)
    end

    it "solves effect size for target power" do
      result = described_class.one_sample(
        sample_size: 30,
        alpha: 0.05,
        power: 0.8
      )

      expect(result.effect_size).to be_within(1e-6).of(0.5292356151)
    end

    it "solves alpha for target power" do
      result = described_class.one_sample(
        effect_size: 0.5,
        sample_size: 30,
        alpha: nil,
        power: 0.8
      )

      expect(result.alpha).to be_within(1e-6).of(0.0690623911)
    end
  end

  describe ".paired" do
    it "matches Cohen paired-sample exercise" do
      effect_size = 8.0 / (16.0 * Math.sqrt(2.0 * (1.0 - 0.6)))

      result = described_class.paired(
        effect_size:,
        sample_size: 40,
        alpha: 0.05
      )

      expect(result.power).to be_within(1e-7).of(0.9315248253)
    end

    it "uses number of pairs as sample size" do
      paired = described_class.paired(
        effect_size: 0.4,
        sample_size: 25,
        alpha: 0.05
      )
      one_sample = described_class.one_sample(
        effect_size: 0.4,
        sample_size: 25,
        alpha: 0.05
      )

      expect(paired.power).to be_within(1e-12).of(one_sample.power)
    end
  end

  describe ".two_sample" do
    it "matches Cohen exercise 2.1" do
      result = described_class.two_sample(
        effect_size: 2.0 / 2.8,
        sample_size: 30,
        alpha: 0.05
      )

      expect(result.power).to be_within(1e-7).of(0.7764888766)
    end

    it "solves sample size per group for Cohen exercise 2.10" do
      result = described_class.two_sample(
        effect_size: 0.3,
        alpha: 0.05,
        power: 0.75,
        alternative: :greater
      )

      expect(result.sample_size).to be_within(1e-5).of(120.2232017)
      expect(result.required_sample_size).to eq(121)
    end
  end

  it "accepts conventional Cohen effect-size names" do
    named = described_class.one_sample(
      effect_size: :medium,
      sample_size: 30,
      alpha: 0.05
    )
    numeric = described_class.one_sample(
      effect_size: 0.5,
      sample_size: 30,
      alpha: 0.05
    )

    expect(named.power).to be_within(1e-12).of(numeric.power)
  end

  it "preserves direction for one-sided alternatives" do
    greater = described_class.one_sample(
      effect_size: 0.4,
      sample_size: 40,
      alpha: 0.05,
      alternative: :greater
    )
    less = described_class.one_sample(
      effect_size: -0.4,
      sample_size: 40,
      alpha: 0.05,
      alternative: :less
    )

    expect(greater.power).to be_within(1e-10).of(less.power)
  end

  it "requires exactly one unknown parameter" do
    expect do
      described_class.one_sample(
        effect_size: 0.5,
        sample_size: 30,
        alpha: 0.05,
        power: 0.8
      )
    end.to raise_error(StatPower::DomainError, /exactly one/)
  end
end
