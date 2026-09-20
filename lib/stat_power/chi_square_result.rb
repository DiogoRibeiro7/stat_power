# frozen_string_literal: true

module StatPower
  # Immutable result for chi-square power analyses.
  ChiSquareResult = Data.define(
    :degrees_of_freedom,
    :sample_size,
    :power,
    :effect_size,
    :alpha,
    :analysis_method
  ) do
    # Smallest whole-number total sample size not below the solution.
    #
    # @return [Integer]
    def required_sample_size
      sample_size.ceil
    end
  end
end
