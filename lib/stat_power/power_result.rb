# frozen_string_literal: true

module StatPower
  # Immutable result returned by power-analysis solvers.
  PowerResult = Data.define(
    :sample_size,
    :power,
    :effect_size,
    :alpha,
    :alternative,
    :analysis_method
  ) do
    # Smallest integer sample size that is at least the continuous solution.
    #
    # @return [Integer]
    def required_sample_size
      sample_size.ceil
    end
  end
end
