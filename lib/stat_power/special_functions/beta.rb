# frozen_string_literal: true

module StatPower
  module SpecialFunctions
    # Numerical utilities for the beta function.
    module Beta
      MAX_ITERATIONS = 256
      EPSILON = 3e-14
      MIN_DENOMINATOR = 1e-300

      module_function

      # Regularized incomplete beta I_x(a, b).
      #
      # @param x [Numeric] integration limit in [0, 1]
      # @param a [Numeric] first positive shape parameter
      # @param b [Numeric] second positive shape parameter
      # @return [Float]
      def regularized(x, a:, b:)
        value = Float(x)
        shape_a = Float(a)
        shape_b = Float(b)
        validate_arguments!(value, shape_a, shape_b)

        return 0.0 if value.zero?
        return 1.0 if value >= 1.0

        log_beta = log_gamma(shape_a) + log_gamma(shape_b) - log_gamma(shape_a + shape_b)
        front = Math.exp(
          (shape_a * Math.log(value)) +
          (shape_b * Math.log(1.0 - value)) -
          log_beta
        )

        threshold = (shape_a + 1.0) / (shape_a + shape_b + 2.0)
        if value < threshold
          front * continued_fraction(shape_a, shape_b, value) / shape_a
        else
          1.0 - (front * continued_fraction(shape_b, shape_a, 1.0 - value) / shape_b)
        end
      end

      def continued_fraction(a, b, x)
        qab = a + b
        qap = a + 1.0
        qam = a - 1.0

        c = 1.0
        d = stabilize(1.0 - (qab * x / qap))
        d = 1.0 / d
        result = d

        1.upto(MAX_ITERATIONS) do |iteration|
          doubled = 2.0 * iteration
          first = iteration * (b - iteration) * x /
                  ((qam + doubled) * (a + doubled))

          d = 1.0 / stabilize(1.0 + (first * d))
          c = stabilize(1.0 + (first / c))
          result *= d * c

          second = -(a + iteration) * (qab + iteration) * x /
                   ((a + doubled) * (qap + doubled))

          d = 1.0 / stabilize(1.0 + (second * d))
          c = stabilize(1.0 + (second / c))
          delta = d * c
          result *= delta

          return result if (delta - 1.0).abs <= EPSILON
        end

        raise StatPower::ConvergenceError,
              "incomplete beta continued fraction did not converge"
      end
      private_class_method :continued_fraction

      def stabilize(value)
        return value if value.abs >= MIN_DENOMINATOR

        value.negative? ? -MIN_DENOMINATOR : MIN_DENOMINATOR
      end
      private_class_method :stabilize

      def validate_arguments!(x, a, b)
        unless x.finite? && x.between?(0.0, 1.0)
          raise StatPower::DomainError, "x must be finite and lie in [0, 1]"
        end

        return if a.finite? && b.finite? && a.positive? && b.positive?

        raise StatPower::DomainError, "beta shape parameters must be finite and positive"
      end
      private_class_method :validate_arguments!

      def log_gamma(value)
        Math.lgamma(value).first
      end
      private_class_method :log_gamma
    end
  end
end
