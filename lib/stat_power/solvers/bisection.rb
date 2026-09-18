# frozen_string_literal: true

module StatPower
  module Solvers
    # Deterministic bracketed root finding using the bisection method.
    module Bisection
      DEFAULT_ABSOLUTE_TOLERANCE = 1e-10
      DEFAULT_RELATIVE_TOLERANCE = 1e-10
      DEFAULT_MAX_ITERATIONS = 256

      module_function

      # Solve f(x) = 0 on a bracket [lower, upper].
      #
      # The function values at the endpoints must have opposite signs unless
      # one endpoint is itself a root.
      #
      # @param lower [Numeric] lower bracket endpoint
      # @param upper [Numeric] upper bracket endpoint
      # @param absolute_tolerance [Float] absolute interval tolerance
      # @param relative_tolerance [Float] relative interval tolerance
      # @param max_iterations [Integer] maximum number of bisection iterations
      # @yieldparam x [Float] point at which the function is evaluated
      # @yieldreturn [Numeric] function value
      # @return [Float] approximate root
      # @raise [StatPower::DomainError] for an invalid bracket or arguments
      # @raise [StatPower::ConvergenceError] if convergence is not reached
      def solve(
        lower:,
        upper:,
        absolute_tolerance: DEFAULT_ABSOLUTE_TOLERANCE,
        relative_tolerance: DEFAULT_RELATIVE_TOLERANCE,
        max_iterations: DEFAULT_MAX_ITERATIONS,
        &function
      )
        raise ArgumentError, "a function block is required" unless function

        left = Float(lower)
        right = Float(upper)
        abs_tol = Float(absolute_tolerance)
        rel_tol = Float(relative_tolerance)

        validate_arguments!(
          left: left,
          right: right,
          absolute_tolerance: abs_tol,
          relative_tolerance: rel_tol,
          max_iterations: max_iterations
        )

        f_left = finite_function_value!(function.call(left))
        f_right = finite_function_value!(function.call(right))

        return left if f_left.zero?
        return right if f_right.zero?

        unless opposite_signs?(f_left, f_right)
          raise StatPower::DomainError, "root is not bracketed by the supplied interval"
        end

        max_iterations.times do
          midpoint = left + ((right - left) / 2.0)
          f_midpoint = finite_function_value!(function.call(midpoint))

          return midpoint if f_midpoint.zero? || converged?(left, right, midpoint, abs_tol, rel_tol)
          return midpoint if midpoint == left || midpoint == right

          if opposite_signs?(f_left, f_midpoint)
            right = midpoint
            f_right = f_midpoint
          else
            left = midpoint
            f_left = f_midpoint
          end
        end

        raise StatPower::ConvergenceError,
              "bisection did not converge within #{max_iterations} iterations"
      end

      def validate_arguments!(left:, right:, absolute_tolerance:, relative_tolerance:, max_iterations:)
        unless left.finite? && right.finite? && left < right
          raise StatPower::DomainError, "lower and upper must be finite with lower < upper"
        end

        unless absolute_tolerance.finite? && absolute_tolerance.positive?
          raise StatPower::DomainError, "absolute_tolerance must be finite and positive"
        end

        unless relative_tolerance.finite? && relative_tolerance >= 0.0
          raise StatPower::DomainError, "relative_tolerance must be finite and non-negative"
        end

        return if max_iterations.is_a?(Integer) && max_iterations.positive?

        raise StatPower::DomainError, "max_iterations must be a positive integer"
      end
      private_class_method :validate_arguments!

      def finite_function_value!(value)
        numeric_value = Float(value)
        return numeric_value if numeric_value.finite?

        raise StatPower::DomainError, "function values must be finite"
      end
      private_class_method :finite_function_value!

      def opposite_signs?(left, right)
        left.negative? != right.negative?
      end
      private_class_method :opposite_signs?

      def converged?(left, right, midpoint, absolute_tolerance, relative_tolerance)
        width = right - left
        scale = [midpoint.abs, 1.0].max
        width <= [absolute_tolerance, relative_tolerance * scale].max
      end
      private_class_method :converged?
    end
  end
end
