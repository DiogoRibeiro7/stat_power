# frozen_string_literal: true

module StatPower
  module Distributions
    # Central Fisher-Snedecor F distribution utilities.
    module FDistribution
      module_function

      # Probability density function.
      #
      # @param x [Numeric] evaluation point
      # @param numerator_df [Numeric] positive numerator degrees of freedom
      # @param denominator_df [Numeric] positive denominator degrees of freedom
      # @return [Float]
      def pdf(x, numerator_df:, denominator_df:)
        value = Float(x)
        numerator = normalize_df(numerator_df, "numerator_df")
        denominator = normalize_df(denominator_df, "denominator_df")
        raise StatPower::DomainError, "x must be finite" unless value.finite?
        return 0.0 if value.negative?

        if value.zero?
          return Float::INFINITY if numerator < 2.0
          return 1.0 if (numerator - 2.0).abs <= Float::EPSILON

          return 0.0
        end

        shape_a = numerator / 2.0
        shape_b = denominator / 2.0
        ratio = numerator / denominator
        log_beta = Math.lgamma(shape_a).first +
                   Math.lgamma(shape_b).first -
                   Math.lgamma(shape_a + shape_b).first

        log_density = (shape_a * Math.log(ratio)) +
                      ((shape_a - 1.0) * Math.log(value)) -
                      log_beta -
                      ((shape_a + shape_b) * Math.log(1.0 + (ratio * value)))

        Math.exp(log_density)
      end

      # Cumulative distribution function.
      #
      # @return [Float]
      def cdf(x, numerator_df:, denominator_df:)
        value = Float(x)
        numerator = normalize_df(numerator_df, "numerator_df")
        denominator = normalize_df(denominator_df, "denominator_df")
        raise StatPower::DomainError, "x must be finite" unless value.finite?
        return 0.0 if value <= 0.0

        transformed = beta_argument(value, numerator, denominator)
        SpecialFunctions::Beta.regularized(
          transformed,
          a: numerator / 2.0,
          b: denominator / 2.0
        )
      end

      # Survival function P(F > x), using the complementary beta form.
      #
      # @return [Float]
      def survival(x, numerator_df:, denominator_df:)
        value = Float(x)
        numerator = normalize_df(numerator_df, "numerator_df")
        denominator = normalize_df(denominator_df, "denominator_df")
        raise StatPower::DomainError, "x must be finite" unless value.finite?
        return 1.0 if value <= 0.0

        transformed = beta_argument(value, numerator, denominator)
        SpecialFunctions::Beta.regularized(
          1.0 - transformed,
          a: denominator / 2.0,
          b: numerator / 2.0
        )
      end

      # Quantile function.
      #
      # @return [Float]
      def quantile(probability, numerator_df:, denominator_df:)
        target = Float(probability)
        validate_probability!(target)
        numerator = normalize_df(numerator_df, "numerator_df")
        denominator = normalize_df(denominator_df, "denominator_df")

        return 0.0 if target.zero?
        return Float::INFINITY if target >= 1.0

        upper = quantile_upper_bound(target, numerator, denominator)

        Solvers::Bisection.solve(lower: 0.0, upper:) do |candidate|
          cdf(
            candidate,
            numerator_df: numerator,
            denominator_df: denominator
          ) - target
        end
      end

      def quantile_upper_bound(target, numerator, denominator)
        upper = 1.0

        while cdf(upper, numerator_df: numerator, denominator_df: denominator) < target
          upper *= 2.0
          if upper > 1e15
            raise StatPower::ConvergenceError,
                  "unable to bracket F quantile"
          end
        end

        upper
      end
      private_class_method :quantile_upper_bound

      def beta_argument(value, numerator, denominator)
        numerator * value / ((numerator * value) + denominator)
      end
      private_class_method :beta_argument

      def normalize_df(value, name)
        degrees = Float(value)
        return degrees if degrees.finite? && degrees.positive?

        raise StatPower::DomainError, "#{name} must be finite and positive"
      rescue ArgumentError, TypeError
        raise StatPower::DomainError, "#{name} must be numeric"
      end
      private_class_method :normalize_df

      def validate_probability!(probability)
        return if probability.finite? && probability.between?(0.0, 1.0)

        raise StatPower::DomainError, "probability must be finite and lie in [0, 1]"
      end
      private_class_method :validate_probability!
    end
  end
end
