# frozen_string_literal: true

RSpec.describe StatPower::EffectSize::Proportion do
  describe ".cohen_h" do
    it "matches the Cohen arcsine definition" do
      result = described_class.cohen_h(p1: 0.5, p2: 0.4)

      expect(result).to be_within(1e-12).of(0.20135792079033088)
    end

    it "preserves direction" do
      forward = described_class.cohen_h(p1: 0.5, p2: 0.4)
      reverse = described_class.cohen_h(p1: 0.4, p2: 0.5)

      expect(reverse).to be_within(1e-12).of(-forward)
    end

    it "handles probability boundaries" do
      expect(described_class.cohen_h(p1: 1.0, p2: 0.0)).to be_within(1e-12).of(Math::PI)
    end

    it "rejects invalid probabilities" do
      expect do
        described_class.cohen_h(p1: 1.1, p2: 0.4)
      end.to raise_error(StatPower::DomainError)
    end
  end
end
