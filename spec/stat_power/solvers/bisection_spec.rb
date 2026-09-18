# frozen_string_literal: true

RSpec.describe StatPower::Solvers::Bisection do
  describe ".solve" do
    it "solves a bracketed nonlinear equation" do
      root = described_class.solve(lower: 1.0, upper: 2.0) { |x| (x * x) - 2.0 }

      expect(root).to be_within(1e-9).of(Math.sqrt(2.0))
    end

    it "returns an endpoint when it is exactly a root" do
      root = described_class.solve(lower: 0.0, upper: 2.0) { |x| x }

      expect(root).to eq(0.0)
    end

    it "rejects an interval that does not bracket a root" do
      expect do
        described_class.solve(lower: 2.0, upper: 3.0) { |x| (x * x) - 2.0 }
      end.to raise_error(StatPower::DomainError, /not bracketed/)
    end

    it "rejects invalid bounds" do
      expect do
        described_class.solve(lower: 2.0, upper: 1.0) { |x| x - 1.5 }
      end.to raise_error(StatPower::DomainError)
    end

    it "rejects non-finite function values" do
      expect do
        described_class.solve(lower: -1.0, upper: 1.0) { Float::NAN }
      end.to raise_error(StatPower::DomainError, /function values/)
    end

    it "raises when the iteration budget is exhausted" do
      expect do
        described_class.solve(
          lower: 1.0,
          upper: 2.0,
          absolute_tolerance: 1e-15,
          relative_tolerance: 0.0,
          max_iterations: 1
        ) { |x| (x * x) - 2.0 }
      end.to raise_error(StatPower::ConvergenceError)
    end
  end
end
