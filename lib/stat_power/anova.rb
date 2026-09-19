# frozen_string_literal: true

module StatPower
  # Power analysis for balanced one-way analysis of variance.
  #
  # The statistical parameterisation follows CRAN pwr.anova.test. Exactly one
  # of groups, sample_size, effect_size, alpha, and power must be nil.
  module Anova
    GROUPS_LOWER = 2.0 + 1e-10
    GROUPS_UPPER = 100.0
    SAMPLE_SIZE_LOWER = 2.0 + 1e-10
    SAMPLE_SIZE_MAX = 1e9
    EFFECT_SIZE_LOWER = 1e-7
    EFFECT_SIZE_MAX = 1e4
    PROBABILITY_EPSILON = 1e-10

    module_function

    # Solve one missing parameter of a balanced one-way ANOVA power analysis.
    #
    # @param groups [Numeric, nil] number of groups
    # @param sample_size [Numeric, nil] observations per group
    # @param effect_size [Numeric, Symbol, String, nil] Cohen's f
    # @param alpha [Numeric, nil] Type I error probability
    # @param power [Numeric, nil] statistical power
    # @return [StatPower::AnovaResult]
    def solve(
      groups: nil,
      sample_size: nil,
      effect_size: nil,
      alpha: 0.05,
      power: nil
    )
      ensure_one_missing!(groups, sample_size, effect_size, alpha, power)

      groups = optional_float(groups)
      sample_size = optional_float(sample_size)
      effect_size = normalize_effect_size(effect_size)
      alpha = optional_float(alpha)
      power = optional_float(power)

      validate_known_values!(
        groups:,
        sample_size:,
        effect_size:,
        alpha:,
        power:
      )

      groups, sample_size, effect_size, alpha, power = solve_missing(
        groups:,
        sample_size:,
        effect_size:,
        alpha:,
        power:
      )

      AnovaResult.new(
        groups:,
        sample_size:,
        power:,
        effect_size:,
        alpha:,
        analysis_method: "balanced one-way analysis of variance power calculation"
      )
    end

    def solve_missing(groups:, sample_size:, effect_size:, alpha:, power:)
      if power.nil?
        power = power_for(
          groups:,
          sample_size:,
          effect_size:,
          alpha:
        )
      elsif groups.nil?
        groups = solve_groups(
          sample_size:,
          effect_size:,
          alpha:,
          power:
        )
      elsif sample_size.nil?
        sample_size = solve_sample_size(
          groups:,
          effect_size:,
          alpha:,
          power:
        )
      elsif effect_size.nil?
        effect_size = solve_effect_size(
          groups:,
          sample_size:,
          alpha:,
          power:
        )
      elsif alpha.nil?
        alpha = solve_alpha(
          groups:,
          sample_size:,
          effect_size:,
          power:
        )
      end

      [groups, sample_size, effect_size, alpha, power]
    end
    private_class_method :solve_missing

    def power_for(groups:, sample_size:, effect_size:, alpha:)
      numerator_df = groups - 1.0
      denominator_df = (sample_size - 1.0) * groups
      noncentrality = groups * sample_size * effect_size * effect_size

      critical = Distributions::FDistribution.quantile(
        1.0 - alpha,
        numerator_df:,
        denominator_df:
      )

      Distributions::NoncentralF.survival(
        critical,
        numerator_df:,
        denominator_df:,
        noncentrality:
      )
    end
    private_class_method :power_for

    def solve_groups(sample_size:, effect_size:, alpha:, power:)
      Solvers::Bisection.solve(
        lower: GROUPS_LOWER,
        upper: GROUPS_UPPER
      ) do |candidate|
        power_for(
          groups: candidate,
          sample_size:,
          effect_size:,
          alpha:
        ) - power
      end
    end
    private_class_method :solve_groups

    def solve_sample_size(groups:, effect_size:, alpha:, power:)
      upper = bracket_sample_size(
        groups:,
        effect_size:,
        alpha:,
        power:
      )

      Solvers::Bisection.solve(
        lower: SAMPLE_SIZE_LOWER,
        upper:,
        absolute_tolerance: 1e-7,
        relative_tolerance: 1e-9
      ) do |candidate|
        power_for(
          groups:,
          sample_size: candidate,
          effect_size:,
          alpha:
        ) - power
      end
    end
    private_class_method :solve_sample_size

    def bracket_sample_size(groups:, effect_size:, alpha:, power:)
      upper = 4.0

      while upper < SAMPLE_SIZE_MAX
        achieved = power_for(
          groups:,
          sample_size: upper,
          effect_size:,
          alpha:
        )
        return upper if achieved >= power

        upper *= 2.0
      end

      raise StatPower::DomainError,
            "target power cannot be bracketed within the supported sample-size range"
    end
    private_class_method :bracket_sample_size

    def solve_effect_size(groups:, sample_size:, alpha:, power:)
      upper = bracket_effect_size(
        groups:,
        sample_size:,
        alpha:,
        power:
      )

      Solvers::Bisection.solve(
        lower: EFFECT_SIZE_LOWER,
        upper:
      ) do |candidate|
        power_for(
          groups:,
          sample_size:,
          effect_size: candidate,
          alpha:
        ) - power
      end
    end
    private_class_method :solve_effect_size

    def bracket_effect_size(groups:, sample_size:, alpha:, power:)
      upper = 0.5

      while upper < EFFECT_SIZE_MAX
        achieved = power_for(
          groups:,
          sample_size:,
          effect_size: upper,
          alpha:
        )
        return upper if achieved >= power

        upper *= 2.0
      end

      raise StatPower::DomainError,
            "target power cannot be bracketed within the supported effect-size range"
    end
    private_class_method :bracket_effect_size

    def solve_alpha(groups:, sample_size:, effect_size:, power:)
      Solvers::Bisection.solve(
        lower: PROBABILITY_EPSILON,
        upper: 1.0 - PROBABILITY_EPSILON
      ) do |candidate|
        power_for(
          groups:,
          sample_size:,
          effect_size:,
          alpha: candidate
        ) - power
      end
    end
    private_class_method :solve_alpha

    def ensure_one_missing!(*values)
      return if values.count(&:nil?) == 1

      raise StatPower::DomainError,
            "exactly one of groups, sample_size, effect_size, alpha, and power must be nil"
    end
    private_class_method :ensure_one_missing!

    def normalize_effect_size(value)
      return nil if value.nil?
      return EffectSize::Conventional.resolve(test: :anov, size: value) if value.is_a?(String) || value.is_a?(Symbol)

      Float(value)
    rescue ArgumentError, TypeError
      raise StatPower::DomainError, "effect_size must be numeric or a conventional size"
    end
    private_class_method :normalize_effect_size

    def optional_float(value)
      value.nil? ? nil : Float(value)
    rescue ArgumentError, TypeError
      raise StatPower::DomainError, "numeric parameters must be coercible to Float"
    end
    private_class_method :optional_float

    def validate_known_values!(groups:, sample_size:, effect_size:, alpha:, power:)
      validate_groups!(groups) if groups
      validate_sample_size!(sample_size) if sample_size
      validate_effect_size!(effect_size) if effect_size
      validate_probability!("alpha", alpha) if alpha
      validate_probability!("power", power) if power
    end
    private_class_method :validate_known_values!

    def validate_groups!(groups)
      return if groups.finite? && groups >= 2.0

      raise StatPower::DomainError, "groups must be finite and at least 2"
    end
    private_class_method :validate_groups!

    def validate_sample_size!(sample_size)
      return if sample_size.finite? && sample_size >= 2.0

      raise StatPower::DomainError, "sample_size must be finite and at least 2"
    end
    private_class_method :validate_sample_size!

    def validate_effect_size!(effect_size)
      return if effect_size.finite? && !effect_size.negative?

      raise StatPower::DomainError, "effect_size must be finite and non-negative"
    end
    private_class_method :validate_effect_size!

    def validate_probability!(name, value)
      return if value.finite? && value.positive? && value < 1.0

      raise StatPower::DomainError, "#{name} must lie strictly between 0 and 1"
    end
    private_class_method :validate_probability!
  end
end
