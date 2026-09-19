# frozen_string_literal: true

module StatPower
  # Power analysis for general linear models using Cohen's f².
  #
  # The statistical parameterisation follows CRAN pwr.f2.test. Exactly one of
  # numerator_df, denominator_df, effect_size, alpha, and power must be nil.
  module F2
    DF_LOWER = 1e-10
    DF_UPPER = 1e9
    EFFECT_SIZE_LOWER = 1e-10
    EFFECT_SIZE_UPPER = 1e4
    PROBABILITY_EPSILON = 1e-10

    module_function

    # Solve one missing parameter of a general linear-model power analysis.
    #
    # @param numerator_df [Numeric, nil] numerator degrees of freedom, u
    # @param denominator_df [Numeric, nil] denominator degrees of freedom, v
    # @param effect_size [Numeric, Symbol, String, nil] Cohen's f²
    # @param alpha [Numeric, nil] Type I error probability
    # @param power [Numeric, nil] statistical power
    # @return [StatPower::F2Result]
    def solve(
      numerator_df: nil,
      denominator_df: nil,
      effect_size: nil,
      alpha: 0.05,
      power: nil
    )
      ensure_one_missing!(
        numerator_df,
        denominator_df,
        effect_size,
        alpha,
        power
      )

      numerator_df = optional_float(numerator_df)
      denominator_df = optional_float(denominator_df)
      effect_size = normalize_effect_size(effect_size)
      alpha = optional_float(alpha)
      power = optional_float(power)

      validate_known_values!(
        numerator_df:,
        denominator_df:,
        effect_size:,
        alpha:,
        power:
      )

      numerator_df, denominator_df, effect_size, alpha, power = solve_missing(
        numerator_df:,
        denominator_df:,
        effect_size:,
        alpha:,
        power:
      )

      F2Result.new(
        numerator_df:,
        denominator_df:,
        power:,
        effect_size:,
        alpha:,
        analysis_method: "general linear model power calculation"
      )
    end

    def solve_missing(numerator_df:, denominator_df:, effect_size:, alpha:, power:)
      if power.nil?
        power = power_for(
          numerator_df:,
          denominator_df:,
          effect_size:,
          alpha:
        )
      elsif numerator_df.nil?
        numerator_df = solve_numerator_df(
          denominator_df:,
          effect_size:,
          alpha:,
          power:
        )
      elsif denominator_df.nil?
        denominator_df = solve_denominator_df(
          numerator_df:,
          effect_size:,
          alpha:,
          power:
        )
      elsif effect_size.nil?
        effect_size = solve_effect_size(
          numerator_df:,
          denominator_df:,
          alpha:,
          power:
        )
      elsif alpha.nil?
        alpha = solve_alpha(
          numerator_df:,
          denominator_df:,
          effect_size:,
          power:
        )
      end

      [numerator_df, denominator_df, effect_size, alpha, power]
    end
    private_class_method :solve_missing

    def power_for(numerator_df:, denominator_df:, effect_size:, alpha:)
      noncentrality = effect_size * (numerator_df + denominator_df + 1.0)

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

    def solve_numerator_df(denominator_df:, effect_size:, alpha:, power:)
      Solvers::Bisection.solve(
        lower: DF_LOWER,
        upper: DF_UPPER
      ) do |candidate|
        power_for(
          numerator_df: candidate,
          denominator_df:,
          effect_size:,
          alpha:
        ) - power
      end
    end
    private_class_method :solve_numerator_df

    def solve_denominator_df(numerator_df:, effect_size:, alpha:, power:)
      Solvers::Bisection.solve(
        lower: DF_LOWER,
        upper: DF_UPPER
      ) do |candidate|
        power_for(
          numerator_df:,
          denominator_df: candidate,
          effect_size:,
          alpha:
        ) - power
      end
    end
    private_class_method :solve_denominator_df

    def solve_effect_size(numerator_df:, denominator_df:, alpha:, power:)
      Solvers::Bisection.solve(
        lower: EFFECT_SIZE_LOWER,
        upper: EFFECT_SIZE_UPPER
      ) do |candidate|
        power_for(
          numerator_df:,
          denominator_df:,
          effect_size: candidate,
          alpha:
        ) - power
      end
    end
    private_class_method :solve_effect_size

    def solve_alpha(numerator_df:, denominator_df:, effect_size:, power:)
      Solvers::Bisection.solve(
        lower: PROBABILITY_EPSILON,
        upper: 1.0 - PROBABILITY_EPSILON
      ) do |candidate|
        power_for(
          numerator_df:,
          denominator_df:,
          effect_size:,
          alpha: candidate
        ) - power
      end
    end
    private_class_method :solve_alpha

    def ensure_one_missing!(*values)
      return if values.count(&:nil?) == 1

      raise StatPower::DomainError,
            "exactly one of numerator_df, denominator_df, effect_size, alpha, and power must be nil"
    end
    private_class_method :ensure_one_missing!

    def normalize_effect_size(value)
      return nil if value.nil?
      return EffectSize::Conventional.resolve(test: :f2, size: value) if value.is_a?(String) || value.is_a?(Symbol)

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

    def validate_known_values!(numerator_df:, denominator_df:, effect_size:, alpha:, power:)
      validate_df!("numerator_df", numerator_df) if numerator_df
      validate_df!("denominator_df", denominator_df) if denominator_df
      validate_effect_size!(effect_size) if effect_size
      validate_probability!("alpha", alpha) if alpha
      validate_probability!("power", power) if power
    end
    private_class_method :validate_known_values!

    def validate_df!(name, value)
      return if value.finite? && value.positive?

      raise StatPower::DomainError, "#{name} must be finite and positive"
    end
    private_class_method :validate_df!

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
