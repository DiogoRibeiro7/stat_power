# frozen_string_literal: true

module StatPower
  # Power analysis for tests of a Pearson correlation coefficient.
  #
  # The statistical parameterisation follows CRAN pwr.r.test, including the
  # Fisher z transform and the package's bias correction convention.
  module Correlation
    SAMPLE_SIZE_LOWER = 4.0 + 1e-10
    SAMPLE_SIZE_UPPER = 1e9
    PROBABILITY_EPSILON = 1e-10
    CORRELATION_EPSILON = 1e-10

    CORRELATION_BOUNDS = {
      two_sided: [CORRELATION_EPSILON, 1.0 - CORRELATION_EPSILON],
      less: [-1.0 + CORRELATION_EPSILON, 1.0 - CORRELATION_EPSILON],
      greater: [-1.0 + CORRELATION_EPSILON, 1.0 - CORRELATION_EPSILON]
    }.freeze

    module_function

    # Solve one missing parameter of a correlation power analysis.
    #
    # Exactly one of correlation, sample_size, alpha, and power must be nil.
    #
    # @param correlation [Numeric, Symbol, String, nil] hypothesized Pearson r
    # @param sample_size [Numeric, nil] number of observations
    # @param alpha [Numeric, nil] Type I error probability
    # @param power [Numeric, nil] statistical power
    # @param alternative [Symbol, String] two_sided, less, or greater
    # @return [StatPower::PowerResult]
    def solve(
      correlation: nil,
      sample_size: nil,
      alpha: 0.05,
      power: nil,
      alternative: :two_sided
    )
      ensure_one_missing!(correlation, sample_size, alpha, power)

      alternative = normalize_alternative(alternative)
      correlation = normalize_correlation(correlation)
      correlation = correlation.abs if alternative == :two_sided && correlation
      sample_size = optional_float(sample_size)
      alpha = optional_float(alpha)
      power = optional_float(power)

      validate_known_values!(
        correlation:,
        sample_size:,
        alpha:,
        power:
      )

      correlation, sample_size, alpha, power = solve_missing(
        correlation:,
        sample_size:,
        alpha:,
        power:,
        alternative:
      )

      PowerResult.new(
        sample_size:,
        power:,
        effect_size: correlation,
        alpha:,
        alternative:,
        analysis_method: "approximate correlation power calculation (Fisher z transformation)"
      )
    end

    def solve_missing(correlation:, sample_size:, alpha:, power:, alternative:)
      if power.nil?
        power = power_for(
          correlation:,
          sample_size:,
          alpha:,
          alternative:
        )
      elsif correlation.nil?
        correlation = solve_correlation(
          sample_size:,
          alpha:,
          power:,
          alternative:
        )
      elsif sample_size.nil?
        sample_size = solve_sample_size(
          correlation:,
          alpha:,
          power:,
          alternative:
        )
      elsif alpha.nil?
        alpha = solve_alpha(
          correlation:,
          sample_size:,
          power:,
          alternative:
        )
      end

      [correlation, sample_size, alpha, power]
    end
    private_class_method :solve_missing

    def power_for(correlation:, sample_size:, alpha:, alternative:)
      effective_correlation = alternative == :less ? -correlation : correlation
      effective_correlation = effective_correlation.abs if alternative == :two_sided

      critical_tail = alternative == :two_sided ? alpha / 2.0 : alpha
      degrees_of_freedom = sample_size - 2.0
      critical_t = Distributions::StudentT.quantile(
        1.0 - critical_tail,
        degrees_of_freedom:
      )
      critical_r = Math.sqrt(
        (critical_t * critical_t) /
        ((critical_t * critical_t) + degrees_of_freedom)
      )

      transformed_r = Math.atanh(effective_correlation) +
                      (effective_correlation / (2.0 * (sample_size - 1.0)))
      transformed_critical = Math.atanh(critical_r)
      scale = Math.sqrt(sample_size - 3.0)

      first_tail = Distributions::Normal.cdf(
        (transformed_r - transformed_critical) * scale
      )
      return first_tail unless alternative == :two_sided

      first_tail + Distributions::Normal.cdf(
        (-transformed_r - transformed_critical) * scale
      )
    end
    private_class_method :power_for

    def solve_correlation(sample_size:, alpha:, power:, alternative:)
      lower, upper = CORRELATION_BOUNDS.fetch(alternative)

      Solvers::Bisection.solve(lower:, upper:) do |candidate|
        power_for(
          correlation: candidate,
          sample_size:,
          alpha:,
          alternative:
        ) - power
      end
    end
    private_class_method :solve_correlation

    def solve_sample_size(correlation:, alpha:, power:, alternative:)
      Solvers::Bisection.solve(
        lower: SAMPLE_SIZE_LOWER,
        upper: SAMPLE_SIZE_UPPER,
        absolute_tolerance: 1e-7,
        relative_tolerance: 1e-9
      ) do |candidate|
        power_for(
          correlation:,
          sample_size: candidate,
          alpha:,
          alternative:
        ) - power
      end
    end
    private_class_method :solve_sample_size

    def solve_alpha(correlation:, sample_size:, power:, alternative:)
      Solvers::Bisection.solve(
        lower: PROBABILITY_EPSILON,
        upper: 1.0 - PROBABILITY_EPSILON
      ) do |candidate|
        power_for(
          correlation:,
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
            "exactly one of correlation, sample_size, alpha, and power must be nil"
    end
    private_class_method :ensure_one_missing!

    def normalize_correlation(value)
      return nil if value.nil?
      return EffectSize::Conventional.resolve(test: :r, size: value) if value.is_a?(String) || value.is_a?(Symbol)

      Float(value)
    rescue ArgumentError, TypeError
      raise StatPower::DomainError, "correlation must be numeric or a conventional size"
    end
    private_class_method :normalize_correlation

    def optional_float(value)
      value.nil? ? nil : Float(value)
    rescue ArgumentError, TypeError
      raise StatPower::DomainError, "numeric parameters must be coercible to Float"
    end
    private_class_method :optional_float

    def normalize_alternative(value)
      normalized = value.to_s.tr(".-", "_").to_sym
      return normalized if CORRELATION_BOUNDS.key?(normalized)

      raise StatPower::DomainError, "alternative must be two_sided, less, or greater"
    end
    private_class_method :normalize_alternative

    def validate_known_values!(correlation:, sample_size:, alpha:, power:)
      validate_correlation!(correlation) if correlation
      validate_sample_size!(sample_size) if sample_size
      validate_probability!("alpha", alpha) if alpha
      validate_probability!("power", power) if power
    end
    private_class_method :validate_known_values!

    def validate_correlation!(correlation)
      return if correlation.finite? && correlation > -1.0 && correlation < 1.0

      raise StatPower::DomainError, "correlation must be finite and lie strictly between -1 and 1"
    end
    private_class_method :validate_correlation!

    def validate_sample_size!(sample_size)
      return if sample_size.finite? && sample_size >= 4.0

      raise StatPower::DomainError, "sample_size must be finite and at least 4"
    end
    private_class_method :validate_sample_size!

    def validate_probability!(name, value)
      return if value.finite? && value.positive? && value < 1.0

      raise StatPower::DomainError, "#{name} must lie strictly between 0 and 1"
    end
    private_class_method :validate_probability!
  end
end
