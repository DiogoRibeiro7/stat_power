# frozen_string_literal: true

module StatPower
  module SpecialFunctions
    # Numerical utilities for the regularized incomplete gamma functions.
    module Gamma
      MAX_ITERATIONS = 10_000
      EPSILON = 3e-14
      MIN_DENOMINATOR = 1e-300

      module_function

      # Regularized lower incomplete gamma P(a, x).
      #
      # @param a [Numeric] positive shape parameter
      # @param x [Numeric] non-negative evaluation point
      # @return [Float]
      def regularized_lower(a:, x:)
        shape = Float(a)
        value = Float(x)
        validate_arguments!(shape, value)

        return 0.0 if value.zero?

        if value < shape + 1.0
          lower_series(shape, value)
        else
          1.0 - upper_continued_fraction(shape, value)
        end
      end

      # Regularized upper incomplete gamma Q(a, x).
      #
      # @param a [Numeric] positive shape parameter
      # @param x [Numeric] non-negative evaluation point
      # @return [Float]
      def regularized_upper(a:, x:)
        shape = Float(a)
        value = Float(x)
        validate_arguments!(shape, value)

        return 1.0 if value.zero?

        if value < shape + 1.0
          1.0 - lower_series(shape, value)
        else
          upper_continued_fraction(shape, value)
        end
      end

      def lower_series(shape, value)
        term = 1.0 / shape
        sum = term
        shifted_shape = shape

        1.upto(MAX_ITERATIONS) do
          shifted_shape += 1.0
          term *= value / shifted_shape
          sum += term

          return sum * scale_factor(shape, value) if term.abs <= sum.abs * EPSILON
        end

        raise StatPower::ConvergenceError,
              "regularized gamma series did not converge"
      end
      private_class_method :lower_series

      def upper_continued_fraction(shape, value)
        b = value + 1.0 - shape
        c = 1.0 / MIN_DENOMINATOR
        d = 1.0 / stabilize(b)
        result = d

        1.upto(MAX_ITERATIONS) do |iteration|
          coefficient = -iteration * (iteration - shape)
          b += 2.0
          d = 1.0 / stabilize((coefficient * d) + b)
          c = stabilize(b + (coefficient / c))
          delta = d * c
          result *= delta

          return result * scale_factor(shape, value) if (delta - 1.0).abs <= EPSILON
        end

        raise StatPower::ConvergenceError,
              "regularized gamma continued fraction did not converge"
      end
      private_class_method :upper_continued_fraction

      def scale_factor(shape, value)
        Math.exp(
          (-value) +
          (shape * Math.log(value)) -
          Math.lgamma(shape).first
        )
      end
      private_class_method :scale_factor

      def stabilize(value)
        return value if value.abs >= MIN_DENOMINATOR

        value.negative? ? -MIN_DENOMINATOR : MIN_DENOMINATOR
      end
      private_class_method :stabilize

      def validate_arguments!(shape, value)
        unless shape.finite? && shape.positive?
          raise StatPower::DomainError, "gamma shape parameter must be finite and positive"
        end

        return if value.finite? && !value.negative?

        raise StatPower::DomainError, "gamma evaluation point must be finite and non-negative"
      end
      private_class_method :validate_arguments!
    end
  end
end
