# frozen_string_literal: true

RSpec.describe StatPower::Distributions::ChiSquare do
  describe ".cdf" do
    it "matches a reference probability" do
      expect(described_class.cdf(5.0, degrees_of_freedom: 3))
        .to be_within(1e-12).of(0.8282028557032665)
    end
  end

  describe ".survival" do
    it "matches a reference upper tail" do
      expect(described_class.survival(5.0, degrees_of_freedom: 3))
        .to be_within(1e-12).of(0.1717971442967335)
    end
  end

  describe ".quantile" do
    it "matches a 95 percent reference quantile" do
      result = described_class.quantile(
        0.95,
        degrees_of_freedom: 20
      )

      expect(result).to be_within(1e-8).of(31.410432844230918)
    end

    it "round-trips representative probabilities" do
      [0.025, 0.5, 0.95].each do |probability|
        quantile = described_class.quantile(
          probability,
          degrees_of_freedom: 6
        )
        result = described_class.cdf(
          quantile,
          degrees_of_freedom: 6
        )

        expect(result).to be_within(1e-9).of(probability)
      end
    end
  end
end
