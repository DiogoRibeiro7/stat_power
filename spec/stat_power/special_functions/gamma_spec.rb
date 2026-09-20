# frozen_string_literal: true

RSpec.describe StatPower::SpecialFunctions::Gamma do
  describe ".regularized_lower" do
    it "matches a half-shape reference" do
      expect(described_class.regularized_lower(a: 0.5, x: 1.0))
        .to be_within(1e-12).of(0.8427007929497151)
    end

    it "matches a general reference value" do
      expect(described_class.regularized_lower(a: 2.5, x: 1.2))
        .to be_within(1e-12).of(0.20852587940567532)
    end
  end

  describe ".regularized_upper" do
    it "matches a tail reference value" do
      expect(described_class.regularized_upper(a: 10.0, x: 15.0))
        .to be_within(1e-12).of(0.06985366069940986)
    end

    it "is complementary to the lower function" do
      lower = described_class.regularized_lower(a: 5.0, x: 0.2)
      upper = described_class.regularized_upper(a: 5.0, x: 0.2)

      expect(lower + upper).to be_within(1e-12).of(1.0)
    end
  end
end
