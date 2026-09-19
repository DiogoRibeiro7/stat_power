# frozen_string_literal: true

RSpec.describe StatPower::Correlation do
  describe ".solve" do
    it "matches Cohen exercise 3.1 for a two-sided test" do
      result = described_class.solve(
        correlation: 0.3,
        sample_size: 50,
        alpha: 0.05
      )

      expect(result.power).to be_within(1e-8).of(0.5715558419)
    end

    it "matches Cohen exercise 3.1 for a greater alternative" do
      result = described_class.solve(
        correlation: 0.3,
        sample_size: 50,
        alpha: 0.05,
        alternative: :greater
      )

      expect(result.power).to be_within(1e-8).of(0.6911394854)
    end

    it "preserves direction for a less alternative" do
      greater = described_class.solve(
        correlation: 0.3,
        sample_size: 50,
        alpha: 0.05,
        alternative: :greater
      )
      less = described_class.solve(
        correlation: -0.3,
        sample_size: 50,
        alpha: 0.05,
        alternative: :less
      )

      expect(less.power).to be_within(1e-12).of(greater.power)
    end

    it "solves sample size for Cohen exercise 3.4" do
      result = described_class.solve(
        correlation: 0.3,
        alpha: 0.05,
        power: 0.8
      )

      expect(result.sample_size).to be_within(1e-5).of(84.07363774)
      expect(result.required_sample_size).to eq(85)
    end

    it "matches the small-effect one-sided vignette example" do
      result = described_class.solve(
        correlation: 0.1,
        alpha: 0.01,
        power: 0.8,
        alternative: :greater
      )

      expect(result.sample_size).to be_within(1e-4).of(999.2053966)
      expect(result.required_sample_size).to eq(1000)
    end

    it "solves correlation for target power" do
      result = described_class.solve(
        sample_size: 50,
        alpha: 0.05,
        power: 0.8
      )

      expect(result.effect_size).to be_within(1e-6).of(0.3843250613)
    end

    it "solves alpha for target power" do
      result = described_class.solve(
        correlation: 0.3,
        sample_size: 50,
        alpha: nil,
        power: 0.8
      )

      expect(result.alpha).to be_within(1e-6).of(0.191755515)
    end

    it "accepts conventional correlation effect sizes" do
      named = described_class.solve(
        correlation: :medium,
        sample_size: 50,
        alpha: 0.05
      )
      numeric = described_class.solve(
        correlation: 0.3,
        sample_size: 50,
        alpha: 0.05
      )

      expect(named.power).to be_within(1e-12).of(numeric.power)
    end

    it "uses magnitude for two-sided correlations" do
      positive = described_class.solve(
        correlation: 0.3,
        sample_size: 50,
        alpha: 0.05
      )
      negative = described_class.solve(
        correlation: -0.3,
        sample_size: 50,
        alpha: 0.05
      )

      expect(negative.power).to be_within(1e-12).of(positive.power)
      expect(negative.effect_size).to eq(0.3)
    end

    it "requires exactly one unknown parameter" do
      expect do
        described_class.solve(
          correlation: 0.3,
          sample_size: 50,
          alpha: 0.05,
          power: 0.8
        )
      end.to raise_error(StatPower::DomainError, /exactly one/)
    end
  end
end
