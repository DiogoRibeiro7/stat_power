# frozen_string_literal: true

RSpec.describe StatPower::Integration::AdaptiveSimpson do
  describe ".integrate" do
    it "integrates a polynomial" do
      result = described_class.integrate(lower: 0.0, upper: 1.0) do |x|
        x * x
      end

      expect(result).to be_within(1e-11).of(1.0 / 3.0)
    end

    it "integrates a smooth transcendental function" do
      result = described_class.integrate(lower: 0.0, upper: Math::PI) do |x|
        Math.sin(x)
      end

      expect(result).to be_within(1e-10).of(2.0)
    end

    it "rejects invalid bounds" do
      expect do
        described_class.integrate(lower: 1.0, upper: 0.0) { |x| x }
      end.to raise_error(StatPower::DomainError)
    end
  end
end
