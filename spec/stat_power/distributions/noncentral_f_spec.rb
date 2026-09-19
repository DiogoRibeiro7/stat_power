# frozen_string_literal: true

RSpec.describe StatPower::Distributions::NoncentralF do
  describe ".cdf" do
    it "matches a reference probability" do
      result = described_class.cdf(
        2.0,
        numerator_df: 5,
        denominator_df: 10,
        noncentrality: 3.0
      )

      expect(result).to be_within(1e-10).of(0.6391470579975839)
    end

    it "matches a second reference probability" do
      result = described_class.cdf(
        1.0,
        numerator_df: 3,
        denominator_df: 20,
        noncentrality: 5.0
      )

      expect(result).to be_within(1e-10).of(0.15469037664410296)
    end

    it "matches a third reference probability" do
      result = described_class.cdf(
        4.0,
        numerator_df: 2,
        denominator_df: 15,
        noncentrality: 2.0
      )

      expect(result).to be_within(1e-10).of(0.8340262949732403)
    end

    it "reduces to the central F distribution when noncentrality is zero" do
      noncentral = described_class.cdf(
        2.0,
        numerator_df: 5,
        denominator_df: 10,
        noncentrality: 0.0
      )
      central = StatPower::Distributions::FDistribution.cdf(
        2.0,
        numerator_df: 5,
        denominator_df: 10
      )

      expect(noncentral).to eq(central)
    end
  end

  describe ".survival" do
    it "matches a reference upper-tail probability" do
      result = described_class.survival(
        2.0,
        numerator_df: 5,
        denominator_df: 10,
        noncentrality: 3.0
      )

      expect(result).to be_within(1e-10).of(0.360852942002416)
    end

    it "is complementary to the CDF" do
      cdf = described_class.cdf(
        1.5,
        numerator_df: 4,
        denominator_df: 30,
        noncentrality: 4.0
      )
      survival = described_class.survival(
        1.5,
        numerator_df: 4,
        denominator_df: 30,
        noncentrality: 4.0
      )

      expect(cdf + survival).to be_within(1e-11).of(1.0)
    end
  end
end
