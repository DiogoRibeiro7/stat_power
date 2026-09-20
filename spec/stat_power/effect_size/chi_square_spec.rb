# frozen_string_literal: true

RSpec.describe StatPower::EffectSize::ChiSquare do
  describe ".goodness_of_fit" do
    it "matches Cohen exercise 7.1" do
      null_probabilities = Array.new(4, 0.25)
      alternative_probabilities = [
        0.375,
        (1.0 - 0.375) / 3.0,
        (1.0 - 0.375) / 3.0,
        (1.0 - 0.375) / 3.0
      ]

      result = described_class.goodness_of_fit(
        null_probabilities:,
        alternative_probabilities:
      )

      expect(result).to be_within(1e-12).of(0.28867513459481287)
    end

    it "rejects probability vectors with different sizes" do
      expect do
        described_class.goodness_of_fit(
          null_probabilities: [0.5, 0.5],
          alternative_probabilities: [0.2, 0.3, 0.5]
        )
      end.to raise_error(StatPower::DomainError)
    end
  end

  describe ".association" do
    it "matches the documented pwr example" do
      probabilities = [
        [0.225, 0.125, 0.125, 0.125],
        [0.16, 0.16, 0.04, 0.04]
      ]

      result = described_class.association(probabilities:)

      expect(result).to be_within(1e-12).of(0.2558646068639514)
    end

    it "rejects non-rectangular tables" do
      expect do
        described_class.association(
          probabilities: [[0.25, 0.25], [0.5]]
        )
      end.to raise_error(StatPower::DomainError)
    end
  end
end
