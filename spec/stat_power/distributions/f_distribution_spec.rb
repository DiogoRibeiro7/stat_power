# frozen_string_literal: true

RSpec.describe StatPower::Distributions::FDistribution do
  describe ".pdf" do
    it "matches a reference density" do
      expect(
        described_class.pdf(
          1.0,
          numerator_df: 5,
          denominator_df: 10
        )
      ).to be_within(1e-12).of(0.4954797834866395)
    end
  end

  describe ".cdf" do
    it "matches a reference probability" do
      expect(
        described_class.cdf(
          2.0,
          numerator_df: 5,
          denominator_df: 10
        )
      ).to be_within(1e-12).of(0.8358050491002611)
    end
  end

  describe ".survival" do
    it "matches a reference upper-tail probability" do
      expect(
        described_class.survival(
          2.0,
          numerator_df: 5,
          denominator_df: 10
        )
      ).to be_within(1e-12).of(0.16419495089973887)
    end
  end

  describe ".quantile" do
    it "matches a 95 percent reference quantile" do
      result = described_class.quantile(
        0.95,
        numerator_df: 5,
        denominator_df: 10
      )

      expect(result).to be_within(1e-8).of(3.3258345304130104)
    end

    it "round-trips representative probabilities" do
      [0.025, 0.5, 0.95].each do |probability|
        quantile = described_class.quantile(
          probability,
          numerator_df: 4,
          denominator_df: 20
        )
        result = described_class.cdf(
          quantile,
          numerator_df: 4,
          denominator_df: 20
        )

        expect(result).to be_within(1e-9).of(probability)
      end
    end
  end
end
