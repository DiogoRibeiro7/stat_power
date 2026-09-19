# frozen_string_literal: true

module StatPower
  # Immutable result for two-group power analyses with unequal sample sizes.
  UnequalPowerResult = Data.define(
    :sample_size1,
    :sample_size2,
    :power,
    :effect_size,
    :alpha,
    :alternative,
    :method
  ) do
    # Smallest integer first-group size not below the continuous solution.
    #
    # @return [Integer]
    def required_sample_size1
      sample_size1.ceil
    end

    # Smallest integer second-group size not below the continuous solution.
    #
    # @return [Integer]
    def required_sample_size2
      sample_size2.ceil
    end

    # Total continuous sample size across both groups.
    #
    # @return [Float]
    def total_sample_size
      sample_size1 + sample_size2
    end

    # Total integer sample size after independently rounding both groups up.
    #
    # @return [Integer]
    def required_total_sample_size
      required_sample_size1 + required_sample_size2
    end
  end
end
