# frozen_string_literal: true

RSpec.describe StatPower::EffectSize::Conventional do
  describe ".resolve" do
    it "returns the pwr conventional values" do
      expect(described_class.resolve(test: :t, size: :small)).to eq(0.2)
      expect(described_class.resolve(test: :anov, size: :medium)).to eq(0.25)
      expect(described_class.resolve(test: :f2, size: :large)).to eq(0.35)
    end

    it "accepts string keys" do
      expect(described_class.resolve(test: "r", size: "medium")).to eq(0.3)
    end

    it "rejects unknown test families" do
      expect do
        described_class.resolve(test: :unknown, size: :small)
      end.to raise_error(StatPower::DomainError)
    end
  end
end
