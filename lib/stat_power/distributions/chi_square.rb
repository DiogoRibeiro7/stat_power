# frozen_string_literal: true

module StatPower
  module Distributions
    # Central chi-square distribution utilities.
    module ChiSquare
      module_function

      # Probability density function.
      #
      # @param x [Numeric] evaluation point
      # @param degrees_of_freedom [Numeric] positive degrees of freedom
      # @return [Float]
      def pdf(x, degrees_of_freedom:)
        value = Float(x)
        df = normalize_degrees_of_freedom(degrees_of_freedom)
        raise StatPower::DomainError, "x must be finite" unless value.finite?
        return 0.0 if value.negative?

        if value.zero?
          return Float::INFINITY if df < 2.0
          return 0.5 if (df - 2.0).abs <= Float::EPSILON

          return 0.0
        end

        shape = df / 2.0
        log_density = ((shape - 1.0) * Math.log(value)) -
                      (value / 2.0) -
                      (shape * Math.log(2.0)) -
                      Math.lgamma(shape).first

        Math.exp(log_density)
      end

      # Cumulative distribution function.
      #
      # @return [Float]
      def cdf(x, degrees_of_freedom:)
        value = Float(x)
        df = normalize_degrees_of_freedom(degrees_of_freedom)
        raise StatPower::DomainError, "x must be finite" unless value.finite?
        return 0.0 if value <= 0.0

        SpecialFunctions::Gamma.regularized_lower(
          a: df / 2.0,
          x: value / 2.0
        )
      end

      # Survival function P(X > x).
      #
      # @return [Float]
      def survival(x, degrees_of_freedom:)
        value = Float(x)
        df = normalize_degrees_of_freedom(degrees_of_freedom)
        raise StatPower::DomainError, "x must be finite" unless value.finite?
        return 1.0 if value <= 0.0

        SpecialFunctions::Gamma.regularized_upper(
          a: df / 2.0,
          x: value / 2.0
        )
      end

      # Quantile function.
      #
      # @return [Float]
      def quantile(probability, degrees_of_freedom:)
        target = Float(probability)
        validate_probability!(target)
        df = normalize_degrees_of_freedom(degrees_of_freedom)

        return 0.0 if target.zero?
        return Float::INFINITY if target >= 1.0

        upper = quantile_upper_bound(target, df)

        Solvers::Bisection.solve(lower: 0.0, upper:) do |candidate|
          cdf(candidate, degrees_of_freedom: df) - target
        end
      end

      def quantile_upper_bound(target, degrees_of_freedom)
        upper = [degrees_of_freedom, 1.0].max

        while cdf(upper, degrees_of_freedom:) < target
          upper *= 2.0
          if upper > 1e15
            raise StatPower::ConvergenceError,
                  "unable to bracket chi-square quantile"
          end
        end

        upper
      end
      private_class_method :quantile_upper_bound

      def normalize_degrees_of_freedom(value)
        df = Float(value)
        return df if df.finite? && df.positive?

        raise StatPower::DomainError, "degrees_of_freedom must be finite and positive"
      rescue ArgumentError, TypeError
        raise StatPower::DomainError, "degrees_of_freedom must be numeric"
      end
      private_class_method :normalize_degrees_of_freedom

      def validate_probability!(probability)
        return if probability.finite? && probability.between?(0.0, 1.0)

        raise StatPower::DomainError, "probability must be finite and lie in [0, 1]"
      end
      private_class_method :validate_probability!
    end
  end
end
