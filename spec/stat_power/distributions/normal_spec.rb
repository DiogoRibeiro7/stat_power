# frozen_string_literal: true

RSpec.describe StatPower::Distributions::Normal do
  describe ".pdf" do
    it "matches the standard normal density at zero" do
      expect(described_class.pdf(0.0)).to be_within(1e-15).of(0.3989422804014327)
    end
  end

  describe ".cdf" do
    it "returns one half at zero" do
      expect(described_class.cdf(0.0)).to eq(0.5)
    end

    it "matches a reference probability" do
      expect(described_class.cdf(1.96)).to be_within(1e-12).of(0.9750021048517795)
    end
  end

  describe ".survival" do
    it "is numerically consistent with the upper tail" do
      expect(described_class.survival(1.96)).to be_within(1e-12).of(0.024997895148220435)
    end
  end

  describe ".quantile" do
    it "returns zero for the median" do
      expect(described_class.quantile(0.5)).to be_within(1e-15).of(0.0)
    end

    it "matches the two-sided 5 percent critical value" do
      expect(described_class.quantile(0.975)).to be_within(1e-8).of(1.959963984540054)
    end

    it "round-trips representative probabilities" do
      [1e-6, 0.025, 0.5, 0.975, 1.0 - 1e-6].each do |probability|
        z = described_class.quantile(probability)
        expect(described_class.cdf(z)).to be_within(1e-8).of(probability)
      end
    end

    it "returns extended-real quantiles at the boundaries" do
      expect(described_class.quantile(0.0)).to eq(-Float::INFINITY)
      expect(described_class.quantile(1.0)).to eq(Float::INFINITY)
    end

    it "rejects invalid probabilities" do
      expect { described_class.quantile(-0.1) }.to raise_error(StatPower::DomainError)
      expect { described_class.quantile(1.1) }.to raise_error(StatPower::DomainError)
      expect { described_class.quantile(Float::NAN) }.to raise_error(StatPower::DomainError)
    end
  end
end
