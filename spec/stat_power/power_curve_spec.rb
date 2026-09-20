# frozen_string_literal: true

RSpec.describe StatPower::PowerCurve do
  describe ".generate" do
    it "generates reusable curve data from an existing solver" do
      points = described_class.generate(sample_sizes: [20, 40, 60]) do |sample_size|
        StatPower::TTest.one_sample(
          effect_size: 0.5,
          sample_size:,
          alpha: 0.05
        )
      end

      expect(points.map(&:sample_size)).to eq([20.0, 40.0, 60.0])
      expect(points.map(&:power)).to all(be_between(0.0, 1.0))
      expect(points.map(&:power)).to eq(points.map(&:power).sort)
    end

    it "accepts a numeric power value directly" do
      points = described_class.generate(sample_sizes: [10, 20]) do |sample_size|
        sample_size / 100.0
      end

      expect(points.map(&:power)).to eq([0.1, 0.2])
    end

    it "preserves the input sample-size order" do
      points = described_class.generate(sample_sizes: [30, 10, 20]) do |sample_size|
        sample_size / 100.0
      end

      expect(points.map(&:sample_size)).to eq([30.0, 10.0, 20.0])
    end

    it "requires at least one sample size" do
      expect do
        described_class.generate(sample_sizes: []) { 0.5 }
      end.to raise_error(StatPower::DomainError, /at least one/)
    end

    it "rejects invalid power values" do
      expect do
        described_class.generate(sample_sizes: [10]) { 1.5 }
      end.to raise_error(StatPower::DomainError, /\[0, 1\]/)
    end

    it "requires an evaluation block" do
      expect do
        described_class.generate(sample_sizes: [10])
      end.to raise_error(StatPower::DomainError, /block/)
    end
  end
end
