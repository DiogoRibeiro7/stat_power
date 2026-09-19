# frozen_string_literal: true

RSpec.describe StatPower::Distributions::NoncentralT do
  describe ".cdf" do
    it "matches a positive-tail reference value" do
      result = described_class.cdf(
        1.96,
        degrees_of_freedom: 10,
        noncentrality: 0.5
      )

      expect(result).to be_within(1e-8).of(0.902753381690013)
    end

    it "matches a negative evaluation reference" do
      result = described_class.cdf(
        -1.0,
        degrees_of_freedom: 5,
        noncentrality: 0.5
      )

      expect(result).to be_within(1e-8).of(0.08244409105672337)
    end

    it "matches a second noncentral reference value" do
      result = described_class.cdf(
        2.0,
        degrees_of_freedom: 5,
        noncentrality: 1.0
      )

      expect(result).to be_within(1e-8).of(0.7780746626162148)
    end

    it "reduces exactly at zero to a normal probability" do
      result = described_class.cdf(
        0.0,
        degrees_of_freedom: 10,
        noncentrality: 1.0
      )

      expect(result).to be_within(1e-12).of(0.15865525393145707)
    end

    it "reduces to the central t distribution when noncentrality is zero" do
      noncentral = described_class.cdf(
        1.5,
        degrees_of_freedom: 12,
        noncentrality: 0.0
      )
      central = StatPower::Distributions::StudentT.cdf(
        1.5,
        degrees_of_freedom: 12
      )

      expect(noncentral).to eq(central)
    end
  end

  describe ".survival" do
    it "matches a reference upper-tail probability" do
      result = described_class.survival(
        1.96,
        degrees_of_freedom: 10,
        noncentrality: 0.5
      )

      expect(result).to be_within(1e-8).of(0.09724661830998704)
    end
  end
end
