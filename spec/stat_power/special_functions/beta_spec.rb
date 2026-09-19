# frozen_string_literal: true

RSpec.describe StatPower::SpecialFunctions::Beta do
  describe ".regularized" do
    it "matches a polynomial beta case exactly" do
      expect(described_class.regularized(0.5, a: 2.0, b: 3.0))
        .to be_within(1e-13).of(0.6875)
    end

    it "matches a tail reference value" do
      expect(described_class.regularized(0.25, a: 5.0, b: 0.5))
        .to be_within(1e-12).of(0.00027029574725461765)
    end

    it "matches a general reference value" do
      expect(described_class.regularized(0.8, a: 1.5, b: 2.5))
        .to be_within(1e-12).of(0.96627128455142)
    end

    it "handles boundaries" do
      expect(described_class.regularized(0.0, a: 2.0, b: 3.0)).to eq(0.0)
      expect(described_class.regularized(1.0, a: 2.0, b: 3.0)).to eq(1.0)
    end

    it "rejects invalid arguments" do
      expect do
        described_class.regularized(-0.1, a: 2.0, b: 3.0)
      end.to raise_error(StatPower::DomainError)
    end
  end
end
