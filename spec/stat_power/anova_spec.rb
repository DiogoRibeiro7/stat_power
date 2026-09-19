# frozen_string_literal: true

RSpec.describe StatPower::Anova do
  describe ".solve" do
    it "matches Cohen exercise 8.1" do
      result = described_class.solve(
        groups: 4,
        sample_size: 20,
        effect_size: 0.28,
        alpha: 0.05
      )

      expect(result.power).to be_within(1e-8).of(0.514979292)
    end

    it "solves per-group sample size for Cohen exercise 8.10" do
      result = described_class.solve(
        groups: 4,
        effect_size: 0.28,
        alpha: 0.05,
        power: 0.8
      )

      expect(result.sample_size).to be_within(1e-5).of(35.75789452)
      expect(result.required_sample_size).to eq(36)
      expect(result.required_total_sample_size).to eq(144)
    end

    it "matches the pwr vignette medium-effect example" do
      result = described_class.solve(
        groups: 3,
        effect_size: :medium,
        alpha: 0.01,
        power: 0.9
      )

      expect(result.effect_size).to eq(0.25)
      expect(result.sample_size).to be_within(1e-5).of(94.48713237)
      expect(result.required_sample_size).to eq(95)
    end

    it "solves effect size for target power" do
      result = described_class.solve(
        groups: 4,
        sample_size: 20,
        alpha: 0.05,
        power: 0.8
      )

      expect(result.effect_size).to be_within(1e-6).of(0.3787972421)
    end

    it "solves alpha for target power" do
      result = described_class.solve(
        groups: 4,
        sample_size: 20,
        effect_size: 0.28,
        alpha: nil,
        power: 0.8
      )

      expect(result.alpha).to be_within(1e-6).of(0.2268353016)
    end

    it "solves number of groups continuously" do
      reference = described_class.solve(
        groups: 4,
        sample_size: 20,
        effect_size: 0.28,
        alpha: 0.05
      )

      solved = described_class.solve(
        groups: nil,
        sample_size: 20,
        effect_size: 0.28,
        alpha: 0.05,
        power: reference.power
      )

      expect(solved.groups).to be_within(1e-6).of(4.0)
      expect(solved.required_groups).to eq(4)
    end

    it "requires exactly one unknown parameter" do
      expect do
        described_class.solve(
          groups: 4,
          sample_size: 20,
          effect_size: 0.28,
          alpha: 0.05,
          power: 0.8
        )
      end.to raise_error(StatPower::DomainError, /exactly one/)
    end

    it "rejects fewer than two groups" do
      expect do
        described_class.solve(
          groups: 1,
          sample_size: 20,
          effect_size: 0.28,
          alpha: 0.05
        )
      end.to raise_error(StatPower::DomainError, /at least 2/)
    end
  end
end
