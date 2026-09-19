# frozen_string_literal: true

module StatPower
  # Immutable result for general linear-model power analyses based on Cohen's f².
  F2Result = Data.define(
    :numerator_df,
    :denominator_df,
    :power,
    :effect_size,
    :alpha,
    :analysis_method
  ) do
    # Implied total sample size N = u + v + 1.
    #
    # @return [Float]
    def total_sample_size
      numerator_df + denominator_df + 1.0
    end

    # Smallest whole-number total sample size not below the continuous value.
    #
    # @return [Integer]
    def required_total_sample_size
      total_sample_size.ceil
    end
  end
end
