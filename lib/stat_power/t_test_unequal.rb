# frozen_string_literal: true

module StatPower
  module TTest
    UNEQUAL_ANALYSIS_METHOD = "two-sample t test power calculation for unequal sample sizes"

    module_function

    # Independent two-sample t-test power analysis with unequal group sizes.
    #
    # Exactly one of effect_size, sample_size1, sample_size2, alpha, and power
    # must be nil. Sample sizes are observations in the respective groups.
    #
    # @return [StatPower::UnequalPowerResult]
    def two_sample_unequal(
      effect_size: nil,
      sample_size1: nil,
      sample_size2: nil,
      alpha: 0.05,
      power: nil,
      alternative: :two_sided
    )
      ensure_one_missing!(effect_size, sample_size1, sample_size2, alpha, power)

      alternative = normalize_alternative(alternative)
      effect_size = normalize_effect_size(effect_size)
      sample_size1 = optional_float(sample_size1)
      sample_size2 = optional_float(sample_size2)
      alpha = optional_float(alpha)
      power = optional_float(power)

      validate_unequal_known_values!(
        effect_size:,
        sample_size1:,
        sample_size2:,
        alpha:,
        power:
      )

      effect_size, sample_size1, sample_size2, alpha, power =
        solve_unequal_missing(
          effect_size:,
          sample_size1:,
          sample_size2:,
          alpha:,
          power:,
          alternative:
        )

      UnequalPowerResult.new(
        sample_size1:,
        sample_size2:,
        power:,
        effect_size:,
        alpha:,
        alternative:,
        analysis_method: UNEQUAL_ANALYSIS_METHOD
      )
    end

    def solve_unequal_missing(
      effect_size:,
      sample_size1:,
      sample_size2:,
      alpha:,
      power:,
      alternative:
    )
      if power.nil?
        power = unequal_power_for(
          effect_size:,
          sample_size1:,
          sample_size2:,
          alpha:,
          alternative:
        )
      elsif effect_size.nil?
        effect_size = solve_unequal_effect_size(
          sample_size1:,
          sample_size2:,
          alpha:,
          power:,
          alternative:
        )
      elsif sample_size1.nil?
        sample_size1 = solve_unequal_sample_size(
          fixed_sample_size: sample_size2,
          effect_size:,
          alpha:,
          power:,
          alternative:
        )
      elsif sample_size2.nil?
        sample_size2 = solve_unequal_sample_size(
          fixed_sample_size: sample_size1,
          effect_size:,
          alpha:,
          power:,
          alternative:
        )
      elsif alpha.nil?
        alpha = solve_unequal_alpha(
          effect_size:,
          sample_size1:,
          sample_size2:,
          power:,
          alternative:
        )
      end

      [effect_size, sample_size1, sample_size2, alpha, power]
    end
    private_class_method :solve_unequal_missing

    def unequal_power_for(effect_size:, sample_size1:, sample_size2:, alpha:, alternative:)
      degrees_of_freedom = sample_size1 + sample_size2 - 2.0
      effect = alternative == :two_sided ? effect_size.abs : effect_size
      information = (sample_size1 * sample_size2) / (sample_size1 + sample_size2)
      noncentrality = effect * Math.sqrt(information)

      case alternative
      when :two_sided
        critical = Distributions::StudentT.quantile(
          1.0 - (alpha / 2.0),
          degrees_of_freedom:
        )
        Distributions::NoncentralT.survival(
          critical,
          degrees_of_freedom:,
          noncentrality:
        ) + Distributions::NoncentralT.cdf(
          -critical,
          degrees_of_freedom:,
          noncentrality:
        )
      when :greater
        critical = Distributions::StudentT.quantile(
          1.0 - alpha,
          degrees_of_freedom:
        )
        Distributions::NoncentralT.survival(
          critical,
          degrees_of_freedom:,
          noncentrality:
        )
      when :less
        critical = Distributions::StudentT.quantile(
          alpha,
          degrees_of_freedom:
        )
        Distributions::NoncentralT.cdf(
          critical,
          degrees_of_freedom:,
          noncentrality:
        )
      end
    end
    private_class_method :unequal_power_for

    def solve_unequal_effect_size(sample_size1:, sample_size2:, alpha:, power:, alternative:)
      lower, upper = EFFECT_SIZE_BOUNDS.fetch(alternative)

      Solvers::Bisection.solve(lower:, upper:) do |candidate|
        unequal_power_for(
          effect_size: candidate,
          sample_size1:,
          sample_size2:,
          alpha:,
          alternative:
        ) - power
      end
    end
    private_class_method :solve_unequal_effect_size

    def solve_unequal_sample_size(fixed_sample_size:, effect_size:, alpha:, power:, alternative:)
      upper = bracket_unequal_sample_size(
        fixed_sample_size:,
        effect_size:,
        alpha:,
        power:,
        alternative:
      )

      Solvers::Bisection.solve(
        lower: SAMPLE_SIZE_LOWER,
        upper:,
        absolute_tolerance: 1e-7,
        relative_tolerance: 1e-9
      ) do |candidate|
        unequal_power_for(
          effect_size:,
          sample_size1: fixed_sample_size,
          sample_size2: candidate,
          alpha:,
          alternative:
        ) - power
      end
    end
    private_class_method :solve_unequal_sample_size

    def bracket_unequal_sample_size(fixed_sample_size:, effect_size:, alpha:, power:, alternative:)
      upper = 4.0

      while upper < SAMPLE_SIZE_MAX
        achieved = unequal_power_for(
          effect_size:,
          sample_size1: fixed_sample_size,
          sample_size2: upper,
          alpha:,
          alternative:
        )
        return upper if achieved >= power

        upper *= 2.0
      end

      raise StatPower::DomainError,
            "target power cannot be bracketed within the supported sample-size range"
    end
    private_class_method :bracket_unequal_sample_size

    def solve_unequal_alpha(effect_size:, sample_size1:, sample_size2:, power:, alternative:)
      Solvers::Bisection.solve(
        lower: PROBABILITY_EPSILON,
        upper: 1.0 - PROBABILITY_EPSILON
      ) do |candidate|
        unequal_power_for(
          effect_size:,
          sample_size1:,
          sample_size2:,
          alpha: candidate,
          alternative:
        ) - power
      end
    end
    private_class_method :solve_unequal_alpha

    def validate_unequal_known_values!(effect_size:, sample_size1:, sample_size2:, alpha:, power:)
      validate_finite!("effect_size", effect_size) if effect_size
      validate_sample_size!(sample_size1) if sample_size1
      validate_sample_size!(sample_size2) if sample_size2
      validate_probability!("alpha", alpha) if alpha
      validate_probability!("power", power) if power
    end
    private_class_method :validate_unequal_known_values!
  end
end
