# frozen_string_literal: true

module StatPower
  # Power analysis for one-sample, paired, and equal-size two-sample t tests.
  #
  # The statistical parameterisation follows CRAN pwr.t.test. Exactly one of
  # effect_size, sample_size, alpha, and power must be nil and is solved from
  # the remaining values.
  module TTest
    SAMPLE_SIZE_LOWER = 2.0
    SAMPLE_SIZE_MAX = 1e9
    PROBABILITY_EPSILON = 1e-10

    EFFECT_SIZE_BOUNDS = {
      two_sided: [1e-10, 10.0],
      less: [-10.0, 5.0],
      greater: [-5.0, 10.0]
    }.freeze

    DESIGNS = %i[one_sample paired two_sample].freeze

    ANALYSIS_METHODS = {
      one_sample: "one-sample t test power calculation",
      paired: "paired t test power calculation",
      two_sample: "two-sample t test power calculation"
    }.freeze

    module_function

    # One-sample t-test power analysis.
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
        design: :one_sample,
        effect_size:,
        sample_size:,
        alpha:,
        power:,
        alternative:
      )
    end

    # Paired-sample t-test power analysis.
    #
    # sample_size is the number of pairs.
    #
    # @return [StatPower::PowerResult]
    def paired(
      effect_size: nil,
      sample_size: nil,
      alpha: 0.05,
      power: nil,
      alternative: :two_sided
    )
      solve(
        design: :paired,
        effect_size:,
        sample_size:,
        alpha:,
        power:,
        alternative:
      )
    end

    # Equal-size independent two-sample t-test power analysis.
    #
    # sample_size is the number of observations per group.
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
        design: :two_sample,
        effect_size:,
        sample_size:,
        alpha:,
        power:,
        alternative:
      )
    end

    def solve(design:, effect_size:, sample_size:, alpha:, power:, alternative:)
      validate_design!(design)
      ensure_one_missing!(effect_size, sample_size, alpha, power)

      alternative = normalize_alternative(alternative)
      effect_size = normalize_effect_size(effect_size)
      sample_size = optional_float(sample_size)
      alpha = optional_float(alpha)
      power = optional_float(power)

      validate_known_values!(effect_size:, sample_size:, alpha:, power:)

      effect_size, sample_size, alpha, power = solve_missing(
        design:,
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
        analysis_method: analysis_method(design)
      )
    end
    private_class_method :solve

    def solve_missing(design:, effect_size:, sample_size:, alpha:, power:, alternative:)
      if power.nil?
        power = power_for(design:, effect_size:, sample_size:, alpha:, alternative:)
      elsif effect_size.nil?
        effect_size = solve_effect_size(design:, sample_size:, alpha:, power:, alternative:)
      elsif sample_size.nil?
        sample_size = solve_sample_size(design:, effect_size:, alpha:, power:, alternative:)
      elsif alpha.nil?
        alpha = solve_alpha(design:, effect_size:, sample_size:, power:, alternative:)
      end

      [effect_size, sample_size, alpha, power]
    end
    private_class_method :solve_missing

    def power_for(design:, effect_size:, sample_size:, alpha:, alternative:)
      df = degrees_of_freedom(sample_size, design)
      effect = alternative == :two_sided ? effect_size.abs : effect_size
      noncentrality = effect * noncentrality_scale(sample_size, design)

      case alternative
      when :two_sided
        critical = Distributions::StudentT.quantile(
          1.0 - (alpha / 2.0),
          degrees_of_freedom: df
        )
        Distributions::NoncentralT.survival(
          critical,
          degrees_of_freedom: df,
          noncentrality:
        ) + Distributions::NoncentralT.cdf(
          -critical,
          degrees_of_freedom: df,
          noncentrality:
        )
      when :greater
        critical = Distributions::StudentT.quantile(
          1.0 - alpha,
          degrees_of_freedom: df
        )
        Distributions::NoncentralT.survival(
          critical,
          degrees_of_freedom: df,
          noncentrality:
        )
      when :less
        critical = Distributions::StudentT.quantile(
          alpha,
          degrees_of_freedom: df
        )
        Distributions::NoncentralT.cdf(
          critical,
          degrees_of_freedom: df,
          noncentrality:
        )
      end
    end
    private_class_method :power_for

    def solve_effect_size(design:, sample_size:, alpha:, power:, alternative:)
      lower, upper = EFFECT_SIZE_BOUNDS.fetch(alternative)

      Solvers::Bisection.solve(lower:, upper:) do |candidate|
        power_for(
          design:,
          effect_size: candidate,
          sample_size:,
          alpha:,
          alternative:
        ) - power
      end
    end
    private_class_method :solve_effect_size

    def solve_sample_size(design:, effect_size:, alpha:, power:, alternative:)
      upper = bracket_sample_size(
        design:,
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
        power_for(
          design:,
          effect_size:,
          sample_size: candidate,
          alpha:,
          alternative:
        ) - power
      end
    end
    private_class_method :solve_sample_size

    def bracket_sample_size(design:, effect_size:, alpha:, power:, alternative:)
      upper = 4.0

      while upper < SAMPLE_SIZE_MAX
        achieved = power_for(
          design:,
          effect_size:,
          sample_size: upper,
          alpha:,
          alternative:
        )
        return upper if achieved >= power

        upper *= 2.0
      end

      raise StatPower::DomainError,
            "target power cannot be bracketed within the supported sample-size range"
    end
    private_class_method :bracket_sample_size

    def solve_alpha(design:, effect_size:, sample_size:, power:, alternative:)
      Solvers::Bisection.solve(
        lower: PROBABILITY_EPSILON,
        upper: 1.0 - PROBABILITY_EPSILON
      ) do |candidate|
        power_for(
          design:,
          effect_size:,
          sample_size:,
          alpha: candidate,
          alternative:
        ) - power
      end
    end
    private_class_method :solve_alpha

    def degrees_of_freedom(sample_size, design)
      design == :two_sample ? (2.0 * sample_size) - 2.0 : sample_size - 1.0
    end
    private_class_method :degrees_of_freedom

    def noncentrality_scale(sample_size, design)
      return Math.sqrt(sample_size / 2.0) if design == :two_sample

      Math.sqrt(sample_size)
    end
    private_class_method :noncentrality_scale

    def analysis_method(design)
      ANALYSIS_METHODS.fetch(design)
    end
    private_class_method :analysis_method

    def validate_design!(design)
      return if DESIGNS.include?(design)

      raise StatPower::DomainError, "unsupported t-test design: #{design}"
    end
    private_class_method :validate_design!

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
      return if sample_size.finite? && sample_size >= SAMPLE_SIZE_LOWER

      raise StatPower::DomainError, "sample_size must be finite and at least 2"
    end
    private_class_method :validate_sample_size!

    def validate_probability!(name, value)
      return if value.finite? && value.positive? && value < 1.0

      raise StatPower::DomainError, "#{name} must lie strictly between 0 and 1"
    end
    private_class_method :validate_probability!
  end
end
