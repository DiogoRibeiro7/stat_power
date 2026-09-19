# frozen_string_literal: true

RSpec.describe StatPower::Distributions::StudentT do
  describe ".pdf" do
    it "matches a reference density" do
      expect(described_class.pdf(0.0, degrees_of_freedom: 10))
        .to be_within(1e-12).of(0.38910838396603115)
    end
  end

  describe ".cdf" do
    it "matches a reference probability" do
      expect(described_class.cdf(1.96, degrees_of_freedom: 10))
        .to be_within(1e-11).of(0.9607818798761502)
    end

    it "is symmetric about zero" do
      positive = described_class.cdf(1.2, degrees_of_freedom: 7)
      negative = described_class.cdf(-1.2, degrees_of_freedom: 7)

      expect(positive + negative).to be_within(1e-12).of(1.0)
    end
  end

  describe ".survival" do
    it "matches a reference upper-tail probability" do
      expect(described_class.survival(1.96, degrees_of_freedom: 10))
        .to be_within(1e-11).of(0.039218120123849856)
    end
  end

  describe ".quantile" do
    it "matches a 97.5 percent reference quantile" do
      expect(described_class.quantile(0.975, degrees_of_freedom: 10))
        .to be_within(1e-8).of(2.228138851986274)
    end

    it "round-trips representative probabilities" do
      [0.025, 0.5, 0.95, 0.975].each do |probability|
        quantile = described_class.quantile(
          probability,
          degrees_of_freedom: 30
        )
        result = described_class.cdf(
          quantile,
          degrees_of_freedom: 30
        )

        expect(result).to be_within(1e-9).of(probability)
      end
    end
  end
end
