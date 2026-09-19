# frozen_string_literal: true

module StatPower
  # Power calculations for a normal mean with known variance.
  #
  # The parameterisation follows CRAN pwr's pwr.norm.test: exactly one of
  # effect_size, sample_size, alpha, and power must be omitted and is solved
  # from the remaining values.
  module NormalMean
    SAMPLE_SIZE_LOWER = 1.0 + 1e-10
    SAMPLE_SIZE_UPPER = 1e9
    PROBABILITY_EPSILON = 1e-10

    EFFECT_SIZE_BOUNDS = {
      two_sided: [1e-10, 10.0],
      less: [-10.0, 5.0],
      greater: [-5.0, 10.0]
    }.freeze

    module_function

    # Solve one missing parameter of a normal-mean power analysis.
    #
    # @param effect_size [Numeric, Symbol, String, nil] standardised mean effect
    # @param sample_size [Numeric, nil] number of observations
    # @param alpha [Numeric, nil] Type I error probability
    # @param power [Numeric, nil] statistical power
    # @param alternative [Symbol, String] two_sided, less, or greater
    # @return [StatPower::PowerResult]
    def solve(
      effect_size: nil,
      sample_size: nil,
      alpha: 0.05,
      power: nil,
      alternative: :two_sided
    )
      alternative = normalize_alternative(alternative)
      ensure_one_missing!(effect_size, sample_size, alpha, power)

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
        alternative:
      )

      PowerResult.new(
        sample_size:,
        power:,
        effect_size:,
        alpha:,
        alternative:,
        analysis_method: "normal mean with known variance"
      )
    end

    def solve_missing(effect_size:, sample_size:, alpha:, power:, alternative:)
      if power.nil?
        power = power_for(effect_size:, sample_size:, alpha:, alternative:)
      elsif effect_size.nil?
        effect_size = solve_effect_size(sample_size:, alpha:, power:, alternative:)
      elsif sample_size.nil?
        sample_size = solve_sample_size(effect_size:, alpha:, power:, alternative:)
      elsif alpha.nil?
        alpha = solve_alpha(effect_size:, sample_size:, power:, alternative:)
      end

      [effect_size, sample_size, alpha, power]
    end
    private_class_method :solve_missing

    def power_for(effect_size:, sample_size:, alpha:, alternative:)
      d = alternative == :two_sided ? effect_size.abs : effect_size
      noncentrality = d * Math.sqrt(sample_size)

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

    def solve_effect_size(sample_size:, alpha:, power:, alternative:)
      lower, upper = EFFECT_SIZE_BOUNDS.fetch(alternative)

      Solvers::Bisection.solve(lower:, upper:) do |candidate|
        power_for(
          effect_size: candidate,
          sample_size:,
          alpha:,
          alternative:
        ) - power
      end
    end
    private_class_method :solve_effect_size

    def solve_sample_size(effect_size:, alpha:, power:, alternative:)
      Solvers::Bisection.solve(
        lower: SAMPLE_SIZE_LOWER,
        upper: SAMPLE_SIZE_UPPER
      ) do |candidate|
        power_for(
          effect_size:,
          sample_size: candidate,
          alpha:,
          alternative:
        ) - power
      end
    end
    private_class_method :solve_sample_size

    def solve_alpha(effect_size:, sample_size:, power:, alternative:)
      Solvers::Bisection.solve(
        lower: PROBABILITY_EPSILON,
        upper: 1.0 - PROBABILITY_EPSILON
      ) do |candidate|
        power_for(
          effect_size:,
          sample_size:,
          alpha: candidate,
          alternative:
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

      return EffectSize::Conventional.resolve(test: :t, size: value) if value.is_a?(String) || value.is_a?(Symbol)

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

    def validate_probability!(name, value)
      return if value.finite? && value.positive? && value < 1.0

      raise StatPower::DomainError, "#{name} must lie strictly between 0 and 1"
    end
    private_class_method :validate_probability!
  end
end
