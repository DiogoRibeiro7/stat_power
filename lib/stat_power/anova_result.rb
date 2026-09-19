# frozen_string_literal: true

module StatPower
  # Immutable result for balanced one-way ANOVA power analyses.
  AnovaResult = Data.define(
    :groups,
    :sample_size,
    :power,
    :effect_size,
    :alpha,
    :analysis_method
  ) do
    # Smallest whole-number group count not below the continuous solution.
    #
    # @return [Integer]
    def required_groups
      groups.ceil
    end

    # Smallest whole-number per-group sample size not below the solution.
    #
    # @return [Integer]
    def required_sample_size
      sample_size.ceil
    end

    # Continuous total sample size.
    #
    # @return [Float]
    def total_sample_size
      groups * sample_size
    end

    # Practical total after independently rounding groups and per-group n up.
    #
    # @return [Integer]
    def required_total_sample_size
      required_groups * required_sample_size
    end
  end
end
