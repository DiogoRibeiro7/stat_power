# frozen_string_literal: true

module StatPower
  # Power analysis for chi-square tests using Cohen's w.
  #
  # The statistical parameterisation follows CRAN pwr.chisq.test. Degrees of
  # freedom are required; exactly one of effect_size, sample_size, alpha, and
  # power must be nil.
  module ChiSquare
    SAMPLE_SIZE_LOWER = 1e-10
    SAMPLE_SIZE_UPPER = 1e9
    EFFECT_SIZE_LOWER = 1e-10
    EFFECT_SIZE_UPPER = 10.0
    PROBABILITY_EPSILON = 1e-10

    module_function

    # Solve one missing parameter of a chi-square power analysis.
    #
    # @param degrees_of_freedom [Numeric] positive chi-square degrees of freedom
    # @param effect_size [Numeric, Symbol, String, nil] Cohen's w
    # @param sample_size [Numeric, nil] total number of observations
    # @param alpha [Numeric, nil] Type I error probability
    # @param power [Numeric, nil] statistical power
    # @return [StatPower::ChiSquareResult]
    def solve(
      degrees_of_freedom:,
      effect_size: nil,
      sample_size: nil,
      alpha: 0.05,
      power: nil
    )
      ensure_one_missing!(effect_size, sample_size, alpha, power)

      df = Float(degrees_of_freedom)
      effect_size = normalize_effect_size(effect_size)
      sample_size = optional_float(sample_size)
      alpha = optional_float(alpha)
      power = optional_float(power)

      validate_known_values!(
        degrees_of_freedom: df,
        effect_size:,
        sample_size:,
        alpha:,
        power:
      )

      effect_size, sample_size, alpha, power = solve_missing(
        degrees_of_freedom: df,
        effect_size:,
        sample_size:,
        alpha:,
        power:
      )

      ChiSquareResult.new(
        degrees_of_freedom: df,
        sample_size:,
        power:,
        effect_size:,
        alpha:,
        analysis_method: "chi-square power calculation"
      )
    rescue ArgumentError, TypeError
      raise StatPower::DomainError, "degrees_of_freedom must be numeric"
    end

    def solve_missing(degrees_of_freedom:, effect_size:, sample_size:, alpha:, power:)
      if power.nil?
        power = power_for(
          degrees_of_freedom:,
          effect_size:,
          sample_size:,
          alpha:
        )
      elsif effect_size.nil?
        effect_size = solve_effect_size(
          degrees_of_freedom:,
          sample_size:,
          alpha:,
          power:
        )
      elsif sample_size.nil?
        sample_size = solve_sample_size(
          degrees_of_freedom:,
          effect_size:,
          alpha:,
          power:
        )
      elsif alpha.nil?
        alpha = solve_alpha(
          degrees_of_freedom:,
          effect_size:,
          sample_size:,
          power:
        )
      end

      [effect_size, sample_size, alpha, power]
    end
    private_class_method :solve_missing

    def power_for(degrees_of_freedom:, effect_size:, sample_size:, alpha:)
      noncentrality = sample_size * effect_size * effect_size
      critical = Distributions::ChiSquare.quantile(
        1.0 - alpha,
        degrees_of_freedom:
      )

      Distributions::NoncentralChiSquare.survival(
        critical,
        degrees_of_freedom:,
        noncentrality:
      )
    end
    private_class_method :power_for

    def solve_effect_size(degrees_of_freedom:, sample_size:, alpha:, power:)
      Solvers::Bisection.solve(
        lower: EFFECT_SIZE_LOWER,
        upper: EFFECT_SIZE_UPPER
      ) do |candidate|
        power_for(
          degrees_of_freedom:,
          effect_size: candidate,
          sample_size:,
          alpha:
        ) - power
      end
    end
    private_class_method :solve_effect_size

    def solve_sample_size(degrees_of_freedom:, effect_size:, alpha:, power:)
      Solvers::Bisection.solve(
        lower: SAMPLE_SIZE_LOWER,
        upper: SAMPLE_SIZE_UPPER,
        absolute_tolerance: 1e-7,
        relative_tolerance: 1e-9
      ) do |candidate|
        power_for(
          degrees_of_freedom:,
          effect_size:,
          sample_size: candidate,
          alpha:
        ) - power
      end
    end
    private_class_method :solve_sample_size

    def solve_alpha(degrees_of_freedom:, effect_size:, sample_size:, power:)
      Solvers::Bisection.solve(
        lower: PROBABILITY_EPSILON,
        upper: 1.0 - PROBABILITY_EPSILON
      ) do |candidate|
        power_for(
          degrees_of_freedom:,
          effect_size:,
          sample_size:,
          alpha: candidate
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
      return EffectSize::Conventional.resolve(test: :chisq, size: value) if value.is_a?(String) || value.is_a?(Symbol)

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

    def validate_known_values!(degrees_of_freedom:, effect_size:, sample_size:, alpha:, power:)
      validate_df!(degrees_of_freedom)
      validate_effect_size!(effect_size) if effect_size
      validate_sample_size!(sample_size) if sample_size
      validate_probability!("alpha", alpha) if alpha
      validate_probability!("power", power) if power
    end
    private_class_method :validate_known_values!

    def validate_df!(degrees_of_freedom)
      return if degrees_of_freedom.finite? && degrees_of_freedom.positive?

      raise StatPower::DomainError,
            "degrees_of_freedom must be finite and positive"
    end
    private_class_method :validate_df!

    def validate_effect_size!(effect_size)
      return if effect_size.finite? && !effect_size.negative?

      raise StatPower::DomainError,
            "effect_size must be finite and non-negative"
    end
    private_class_method :validate_effect_size!

    def validate_sample_size!(sample_size)
      return if sample_size.finite? && sample_size.positive?

      raise StatPower::DomainError,
            "sample_size must be finite and positive"
    end
    private_class_method :validate_sample_size!

    def validate_probability!(name, value)
      return if value.finite? && value.positive? && value < 1.0

      raise StatPower::DomainError,
            "#{name} must lie strictly between 0 and 1"
    end
    private_class_method :validate_probability!
  end
end
