# frozen_string_literal: true

module StatPower
  module Distributions
    # Central Student t distribution utilities.
    module StudentT
      module_function

      # Probability density function.
      #
      # @param x [Numeric] evaluation point
      # @param degrees_of_freedom [Numeric] positive degrees of freedom
      # @return [Float]
      def pdf(x, degrees_of_freedom:)
        value = Float(x)
        df = normalize_degrees_of_freedom(degrees_of_freedom)
        return Normal.pdf(value) if df.infinite?

        log_scale = log_gamma((df + 1.0) / 2.0) -
                    log_gamma(df / 2.0) -
                    (0.5 * Math.log(df * Math::PI))
        log_kernel = -((df + 1.0) / 2.0) * Math.log(1.0 + ((value * value) / df))

        Math.exp(log_scale + log_kernel)
      end

      # Cumulative distribution function.
      #
      # @param x [Numeric] evaluation point
      # @param degrees_of_freedom [Numeric] positive degrees of freedom
      # @return [Float]
      def cdf(x, degrees_of_freedom:)
        value = Float(x)
        df = normalize_degrees_of_freedom(degrees_of_freedom)
        return Normal.cdf(value) if df.infinite?
        return 0.5 if value.zero?

        beta_argument = df / (df + (value * value))
        beta = SpecialFunctions::Beta.regularized(
          beta_argument,
          a: df / 2.0,
          b: 0.5
        )

        value.negative? ? 0.5 * beta : 1.0 - (0.5 * beta)
      end

      # Survival function P(T > x).
      #
      # Uses symmetry to avoid subtractive cancellation.
      #
      # @param x [Numeric] evaluation point
      # @param degrees_of_freedom [Numeric] positive degrees of freedom
      # @return [Float]
      def survival(x, degrees_of_freedom:)
        cdf(-Float(x), degrees_of_freedom:)
      end

      # Quantile function.
      #
      # @param probability [Numeric] probability in [0, 1]
      # @param degrees_of_freedom [Numeric] positive degrees of freedom
      # @return [Float]
      def quantile(probability, degrees_of_freedom:)
        target = Float(probability)
        validate_probability!(target)
        df = normalize_degrees_of_freedom(degrees_of_freedom)

        return -Float::INFINITY if target.zero?
        return Float::INFINITY if target >= 1.0
        return 0.0 if target == 0.5
        return Normal.quantile(target) if df.infinite?

        sign = target < 0.5 ? -1.0 : 1.0
        upper_target = target < 0.5 ? 1.0 - target : target
        upper = quantile_upper_bound(upper_target, df)

        root = Solvers::Bisection.solve(lower: 0.0, upper:) do |candidate|
          cdf(candidate, degrees_of_freedom: df) - upper_target
        end

        sign * root
      end

      def quantile_upper_bound(target, degrees_of_freedom)
        upper = 1.0

        while cdf(upper, degrees_of_freedom:) < target
          upper *= 2.0
          if upper > 1e12
            raise StatPower::ConvergenceError,
                  "unable to bracket Student t quantile"
          end
        end

        upper
      end
      private_class_method :quantile_upper_bound

      def normalize_degrees_of_freedom(value)
        df = Float(value)
        return df if df.infinite? && df.positive?
        return df if df.finite? && df.positive?

        raise StatPower::DomainError, "degrees_of_freedom must be positive"
      rescue ArgumentError, TypeError
        raise StatPower::DomainError, "degrees_of_freedom must be numeric"
      end
      private_class_method :normalize_degrees_of_freedom

      def validate_probability!(probability)
        return if probability.finite? && probability.between?(0.0, 1.0)

        raise StatPower::DomainError, "probability must be finite and lie in [0, 1]"
      end
      private_class_method :validate_probability!

      def log_gamma(value)
        Math.lgamma(value).first
      end
      private_class_method :log_gamma
    end
  end
end
