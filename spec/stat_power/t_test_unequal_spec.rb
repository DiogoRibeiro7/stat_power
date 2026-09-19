# frozen_string_literal: true

RSpec.describe "unequal-size two-sample t-test power" do
  describe "StatPower::TTest.two_sample_unequal" do
    it "matches Cohen exercise 2.3 from the pwr documentation" do
      result = StatPower::TTest.two_sample_unequal(
        effect_size: 0.6,
        sample_size1: 90,
        sample_size2: 60,
        alpha: 0.05,
        alternative: :greater
      )

      expect(result.power).to be_within(1e-7).of(0.9737261546)
    end

    it "matches the equal-size two-sample implementation" do
      unequal = StatPower::TTest.two_sample_unequal(
        effect_size: 0.4,
        sample_size1: 80,
        sample_size2: 80,
        alpha: 0.05
      )
      equal = StatPower::TTest.two_sample(
        effect_size: 0.4,
        sample_size: 80,
        alpha: 0.05
      )

      expect(unequal.power).to be_within(1e-10).of(equal.power)
    end

    it "solves the second group sample size" do
      result = StatPower::TTest.two_sample_unequal(
        effect_size: 0.4,
        sample_size1: 80,
        sample_size2: nil,
        alpha: 0.05,
        power: 0.8
      )

      expect(result.sample_size2).to be_within(1e-4).of(129.9221031)
      expect(result.required_sample_size2).to eq(130)
    end

    it "solves either group size symmetrically" do
      reference = StatPower::TTest.two_sample_unequal(
        effect_size: 0.35,
        sample_size1: 70,
        sample_size2: 110,
        alpha: 0.05
      )

      solved_n1 = StatPower::TTest.two_sample_unequal(
        effect_size: 0.35,
        sample_size1: nil,
        sample_size2: 110,
        alpha: 0.05,
        power: reference.power
      )
      solved_n2 = StatPower::TTest.two_sample_unequal(
        effect_size: 0.35,
        sample_size1: 70,
        sample_size2: nil,
        alpha: 0.05,
        power: reference.power
      )

      expect(solved_n1.sample_size1).to be_within(1e-4).of(70.0)
      expect(solved_n2.sample_size2).to be_within(1e-4).of(110.0)
    end

    it "round-trips effect size and alpha" do
      reference = StatPower::TTest.two_sample_unequal(
        effect_size: 0.35,
        sample_size1: 70,
        sample_size2: 110,
        alpha: 0.05
      )

      solved_effect = StatPower::TTest.two_sample_unequal(
        sample_size1: 70,
        sample_size2: 110,
        alpha: 0.05,
        power: reference.power
      )
      solved_alpha = StatPower::TTest.two_sample_unequal(
        effect_size: 0.35,
        sample_size1: 70,
        sample_size2: 110,
        alpha: nil,
        power: reference.power
      )

      expect(solved_effect.effect_size).to be_within(1e-6).of(0.35)
      expect(solved_alpha.alpha).to be_within(1e-6).of(0.05)
    end

    it "accepts conventional effect-size names" do
      named = StatPower::TTest.two_sample_unequal(
        effect_size: :medium,
        sample_size1: 60,
        sample_size2: 90,
        alpha: 0.05
      )
      numeric = StatPower::TTest.two_sample_unequal(
        effect_size: 0.5,
        sample_size1: 60,
        sample_size2: 90,
        alpha: 0.05
      )

      expect(named.power).to be_within(1e-12).of(numeric.power)
    end

    it "requires exactly one unknown parameter" do
      expect do
        StatPower::TTest.two_sample_unequal(
          effect_size: 0.4,
          sample_size1: 60,
          sample_size2: 90,
          alpha: 0.05,
          power: 0.8
        )
      end.to raise_error(StatPower::DomainError, /exactly one/)
    end
  end
end
