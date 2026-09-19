# frozen_string_literal: true

RSpec.describe "unequal-size proportion power" do
  describe "StatPower::Proportion.two_sample_unequal" do
    it "matches Cohen exercise 6.3 from the pwr documentation" do
      result = StatPower::Proportion.two_sample_unequal(
        effect_size: 0.30,
        sample_size1: 80,
        sample_size2: 245,
        alpha: 0.05,
        alternative: :greater
      )

      expect(result.power).to be_within(1e-7).of(0.7532924)
    end

    it "solves n2 for Cohen exercise 6.7 from the pwr documentation" do
      result = StatPower::Proportion.two_sample_unequal(
        effect_size: 0.20,
        sample_size1: 1600,
        sample_size2: nil,
        alpha: 0.01,
        power: 0.9,
        alternative: :two_sided
      )

      expect(result.sample_size2).to be_within(1e-4).of(484.6646)
      expect(result.required_sample_size2).to eq(485)
    end

    it "solves either group size" do
      reference = StatPower::Proportion.two_sample_unequal(
        effect_size: 0.25,
        sample_size1: 120,
        sample_size2: 180,
        alpha: 0.05
      )

      solved_n1 = StatPower::Proportion.two_sample_unequal(
        effect_size: 0.25,
        sample_size1: nil,
        sample_size2: 180,
        alpha: 0.05,
        power: reference.power
      )
      solved_n2 = StatPower::Proportion.two_sample_unequal(
        effect_size: 0.25,
        sample_size1: 120,
        sample_size2: nil,
        alpha: 0.05,
        power: reference.power
      )

      expect(solved_n1.sample_size1).to be_within(1e-5).of(120.0)
      expect(solved_n2.sample_size2).to be_within(1e-5).of(180.0)
    end

    it "round-trips effect size and alpha" do
      reference = StatPower::Proportion.two_sample_unequal(
        effect_size: 0.25,
        sample_size1: 120,
        sample_size2: 180,
        alpha: 0.05
      )

      solved_effect = StatPower::Proportion.two_sample_unequal(
        sample_size1: 120,
        sample_size2: 180,
        alpha: 0.05,
        power: reference.power
      )
      solved_alpha = StatPower::Proportion.two_sample_unequal(
        effect_size: 0.25,
        sample_size1: 120,
        sample_size2: 180,
        alpha: nil,
        power: reference.power
      )

      expect(solved_effect.effect_size).to be_within(1e-7).of(0.25)
      expect(solved_alpha.alpha).to be_within(1e-7).of(0.05)
    end

    it "accepts conventional effect-size names" do
      named = StatPower::Proportion.two_sample_unequal(
        effect_size: :medium,
        sample_size1: 80,
        sample_size2: 245,
        alpha: 0.05
      )
      numeric = StatPower::Proportion.two_sample_unequal(
        effect_size: 0.5,
        sample_size1: 80,
        sample_size2: 245,
        alpha: 0.05
      )

      expect(named.power).to be_within(1e-12).of(numeric.power)
    end

    it "requires exactly one unknown parameter" do
      expect do
        StatPower::Proportion.two_sample_unequal(
          effect_size: 0.3,
          sample_size1: 80,
          sample_size2: 245,
          alpha: 0.05,
          power: 0.8
        )
      end.to raise_error(StatPower::DomainError, /exactly one/)
    end

    it "rejects group sizes below two" do
      expect do
        StatPower::Proportion.two_sample_unequal(
          effect_size: 0.3,
          sample_size1: 1,
          sample_size2: 245,
          alpha: 0.05
        )
      end.to raise_error(StatPower::DomainError, /at least 2/)
    end
  end
end
