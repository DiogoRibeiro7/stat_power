# frozen_string_literal: true

RSpec.describe StatPower::Distributions::NoncentralChiSquare do
  describe ".cdf" do
    it "matches a reference probability" do
      result = described_class.cdf(
        5.0,
        degrees_of_freedom: 3,
        noncentrality: 2.0
      )

      expect(result).to be_within(1e-10).of(0.5934051800831555)
    end

    it "reduces to the central chi-square distribution at zero noncentrality" do
      noncentral = described_class.cdf(
        5.0,
        degrees_of_freedom: 3,
        noncentrality: 0.0
      )
      central = StatPower::Distributions::ChiSquare.cdf(
        5.0,
        degrees_of_freedom: 3
      )

      expect(noncentral).to eq(central)
    end
  end

  describe ".survival" do
    it "matches a Cohen power reference tail" do
      result = described_class.survival(
        7.814727903251179,
        degrees_of_freedom: 3,
        noncentrality: 8.3521
      )

      expect(result).to be_within(1e-10).of(0.6750776570037209)
    end

    it "is complementary to the CDF" do
      cdf = described_class.cdf(
        9.0,
        degrees_of_freedom: 4,
        noncentrality: 3.0
      )
      survival = described_class.survival(
        9.0,
        degrees_of_freedom: 4,
        noncentrality: 3.0
      )

      expect(cdf + survival).to be_within(1e-11).of(1.0)
    end
  end
end
