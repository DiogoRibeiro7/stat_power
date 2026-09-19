# frozen_string_literal: true

module StatPower
  # Power analysis for one- and two-sample proportions using Cohen's arcsine
  # transformation. These methods target CRAN pwr.p.test and pwr.2p.test.
  module Proportion
    SAMPLE_SIZE_LOWER = 2.0 + 1e-10
    SAMPLE_SIZE_UPPER = 1e9
    PROBABILITY_EPSILON = 1e-10

    EFFECT_SIZE_BOUNDS = {
      two_sided: [1e-10, 10.0],
      less: [-10.0, 5.0],
      greater: [-5.0, 10.0]
    }.freeze

    module_function

    # Power analysis for one proportion.
    #
    # Exactly one of effect_size, sample_size, alpha, and power must be nil.
    #
    # @return [StatPower::PowerResult]
    def one_sample(
      effect_size: nil,
      sample_size: nil,
      alpha: 0.05,
      power: nil,
      alternative: :two_sided
    )
      solve(
        effect_size:,
        sample_size:,
        alpha:,
        power:,
        alternative:,
        information_factor: 1.0,
        method: "proportion power calculation for binomial distribution (arcsine transformation)"
      )
    end

    # Power analysis for two proportions with equal sample sizes.
    #
    # sample_size is the number of observations in each group.
    # Exactly one of effect_size, sample_size, alpha, and power must be nil.
    #
    # @return [StatPower::PowerResult]
    def two_sample(
      effect_size: nil,
      sample_size: nil,
      alpha: 0.05,
      power: nil,
      alternative: :two_sided
    )
      solve(
        effect_size:,
        sample_size:,
        alpha:,
        power:,
        alternative:,
        information_factor: 0.5,
        method: "difference of proportion power calculation for binomial distribution (arcsine transformation)"
      )
    end

    # Power analysis for two proportions with unequal sample sizes.
    #
    # Exactly one of effect_size, sample_size1, sample_size2, alpha, and power
    # must be nil.
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
        method: "difference of proportion power calculation for unequal sample sizes"
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
      effect = alternative == :two_sided ? effect_size.abs : effect_size
      information = (sample_size1 * sample_size2) / (sample_size1 + sample_size2)
      noncentrality = effect * Math.sqrt(information)

      case alternative
      when :two_sided
        critical = Distributions::Normal.quantile(1.0 - (alpha / 2.0))
        Distributions::Normal.survival(critical - noncentrality) +
          Distributions::Normal.cdf(-critical - noncentrality)
      when :greater
        critical = Distributions::Normal.quantile(1.0 - alpha)
        Distributions::Normal.survival(critical - noncentrality)
      when :less
        critical = Distributions::Normal.quantile(alpha)
        Distributions::Normal.cdf(critical - noncentrality)
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
      Solvers::Bisection.solve(
        lower: SAMPLE_SIZE_LOWER,
        upper: SAMPLE_SIZE_UPPER
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

    def solve(effect_size:, sample_size:, alpha:, power:, alternative:, information_factor:, method:)
      ensure_one_missing!(effect_size, sample_size, alpha, power)

      alternative = normalize_alternative(alternative)
      effect_size = normalize_effect_size(effect_size)
      sample_size = optional_float(sample_size)
      alpha = optional_float(alpha)
      power = optional_float(power)

      validate_known_values!(effect_size:, sample_size:, alpha:, power:)

      effect_size, sample_size, alpha, power = solve_missing(
        effect_size:,
        sample_size:,
        alpha:,
        power:,
        alternative:,
        information_factor:
      )

      PowerResult.new(
        sample_size:,
        power:,
        effect_size:,
        alpha:,
        alternative:,
        method:
      )
    end
    private_class_method :solve

    def solve_missing(effect_size:, sample_size:, alpha:, power:, alternative:, information_factor:)
      if power.nil?
        power = power_for(
          effect_size:,
          sample_size:,
          alpha:,
          alternative:,
          information_factor:
        )
      elsif effect_size.nil?
        effect_size = solve_effect_size(
          sample_size:,
          alpha:,
          power:,
          alternative:,
          information_factor:
        )
      elsif sample_size.nil?
        sample_size = solve_sample_size(
          effect_size:,
          alpha:,
          power:,
          alternative:,
          information_factor:
        )
      elsif alpha.nil?
        alpha = solve_alpha(
          effect_size:,
          sample_size:,
          power:,
          alternative:,
          information_factor:
        )
      end

      [effect_size, sample_size, alpha, power]
    end
    private_class_method :solve_missing

    def power_for(effect_size:, sample_size:, alpha:, alternative:, information_factor:)
      effect = alternative == :two_sided ? effect_size.abs : effect_size
      noncentrality = effect * Math.sqrt(sample_size * information_factor)

      case alternative
      when :two_sided
        critical = Distributions::Normal.quantile(1.0 - (alpha / 2.0))
        Distributions::Normal.survival(critical - noncentrality) +
          Distributions::Normal.cdf(-critical - noncentrality)
      when :greater
        critical = Distributions::Normal.quantile(1.0 - alpha)
        Distributions::Normal.survival(critical - noncentrality)
      when :less
        critical = Distributions::Normal.quantile(alpha)
        Distributions::Normal.cdf(critical - noncentrality)
      end
    end
    private_class_method :power_for

    def solve_effect_size(sample_size:, alpha:, power:, alternative:, information_factor:)
      lower, upper = EFFECT_SIZE_BOUNDS.fetch(alternative)

      Solvers::Bisection.solve(lower:, upper:) do |candidate|
        power_for(
          effect_size: candidate,
          sample_size:,
          alpha:,
          alternative:,
          information_factor:
        ) - power
      end
    end
    private_class_method :solve_effect_size

    def solve_sample_size(effect_size:, alpha:, power:, alternative:, information_factor:)
      Solvers::Bisection.solve(
        lower: SAMPLE_SIZE_LOWER,
        upper: SAMPLE_SIZE_UPPER
      ) do |candidate|
        power_for(
          effect_size:,
          sample_size: candidate,
          alpha:,
          alternative:,
          information_factor:
        ) - power
      end
    end
    private_class_method :solve_sample_size

    def solve_alpha(effect_size:, sample_size:, power:, alternative:, information_factor:)
      Solvers::Bisection.solve(
        lower: PROBABILITY_EPSILON,
        upper: 1.0 - PROBABILITY_EPSILON
      ) do |candidate|
        power_for(
          effect_size:,
          sample_size:,
          alpha: candidate,
          alternative:,
          information_factor:
        ) - power
      end
    end
    private_class_method :solve_alpha

    def ensure_one_missing!(*values)
      return if values.count(&:nil?) == 1

      raise StatPower::DomainError,
            "exactly one of effect_size, sample_size, alpha, and power must be nil"
    end
    private_class_method :ensure_one_missing!

    def normalize_effect_size(value)
      return nil if value.nil?

      if value.is_a?(String) || value.is_a?(Symbol)
        return EffectSize::Conventional.resolve(test: :p, size: value)
      end

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

    def normalize_alternative(value)
      normalized = value.to_s.tr(".-", "_").to_sym
      return normalized if EFFECT_SIZE_BOUNDS.key?(normalized)

      raise StatPower::DomainError, "alternative must be two_sided, less, or greater"
    end
    private_class_method :normalize_alternative

    def validate_known_values!(effect_size:, sample_size:, alpha:, power:)
      validate_finite!("effect_size", effect_size) if effect_size
      validate_sample_size!(sample_size) if sample_size
      validate_probability!("alpha", alpha) if alpha
      validate_probability!("power", power) if power
    end
    private_class_method :validate_known_values!

    def validate_finite!(name, value)
      return if value.finite?

      raise StatPower::DomainError, "#{name} must be finite"
    end
    private_class_method :validate_finite!

    def validate_sample_size!(sample_size)
      return if sample_size.finite? && sample_size >= 1.0

      raise StatPower::DomainError, "sample_size must be finite and at least 1"
    end
    private_class_method :validate_sample_size!

    def validate_unequal_known_values!(
      effect_size:,
      sample_size1:,
      sample_size2:,
      alpha:,
      power:
    )
      validate_finite!("effect_size", effect_size) if effect_size
      validate_group_size!("sample_size1", sample_size1) if sample_size1
      validate_group_size!("sample_size2", sample_size2) if sample_size2
      validate_probability!("alpha", alpha) if alpha
      validate_probability!("power", power) if power
    end
    private_class_method :validate_unequal_known_values!

    def validate_group_size!(name, sample_size)
      return if sample_size.finite? && sample_size >= 2.0

      raise StatPower::DomainError, "#{name} must be finite and at least 2"
    end
    private_class_method :validate_group_size!

    def validate_probability!(name, value)
      return if value.finite? && value.positive? && value < 1.0

      raise StatPower::DomainError, "#{name} must lie strictly between 0 and 1"
    end
    private_class_method :validate_probability!
  end
end
