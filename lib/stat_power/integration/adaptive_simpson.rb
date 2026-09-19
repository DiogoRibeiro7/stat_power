# frozen_string_literal: true

module StatPower
  module Integration
    # Adaptive Simpson quadrature for smooth one-dimensional integrands.
    module AdaptiveSimpson
      DEFAULT_TOLERANCE = 1e-10
      DEFAULT_MAX_DEPTH = 30

      module_function

      # Numerically integrate a function over a finite interval.
      #
      # @param lower [Numeric] lower integration bound
      # @param upper [Numeric] upper integration bound
      # @param tolerance [Numeric] absolute error target
      # @param max_depth [Integer] maximum recursive subdivision depth
      # @yieldparam x [Float] evaluation point
      # @yieldreturn [Numeric] function value
      # @return [Float] approximate integral
      def integrate(
        lower:,
        upper:,
        tolerance: DEFAULT_TOLERANCE,
        max_depth: DEFAULT_MAX_DEPTH,
        &function
      )
        raise ArgumentError, "a function block is required" unless function

        left = Float(lower)
        right = Float(upper)
        error_target = Float(tolerance)
        validate_arguments!(left, right, error_target, max_depth)

        midpoint = left + ((right - left) / 2.0)
        f_left = finite_value!(function.call(left))
        f_midpoint = finite_value!(function.call(midpoint))
        f_right = finite_value!(function.call(right))
        whole = simpson(left, right, f_left, f_midpoint, f_right)

        recurse(
          function:,
          left:,
          right:,
          f_left:,
          f_midpoint:,
          f_right:,
          whole:,
          tolerance: error_target,
          depth: max_depth
        )
      end

      def recurse(
        function:,
        left:,
        right:,
        f_left:,
        f_midpoint:,
        f_right:,
        whole:,
        tolerance:,
        depth:
      )
        midpoint = left + ((right - left) / 2.0)
        left_midpoint = left + ((midpoint - left) / 2.0)
        right_midpoint = midpoint + ((right - midpoint) / 2.0)

        f_left_midpoint = finite_value!(function.call(left_midpoint))
        f_right_midpoint = finite_value!(function.call(right_midpoint))

        left_area = simpson(left, midpoint, f_left, f_left_midpoint, f_midpoint)
        right_area = simpson(midpoint, right, f_midpoint, f_right_midpoint, f_right)
        refined = left_area + right_area
        correction = refined - whole

        return refined + (correction / 15.0) if depth.zero? || correction.abs <= 15.0 * tolerance

        half_tolerance = tolerance / 2.0
        recurse(
          function:,
          left:,
          right: midpoint,
          f_left:,
          f_midpoint: f_left_midpoint,
          f_right: f_midpoint,
          whole: left_area,
          tolerance: half_tolerance,
          depth: depth - 1
        ) + recurse(
          function:,
          left: midpoint,
          right:,
          f_left: f_midpoint,
          f_midpoint: f_right_midpoint,
          f_right:,
          whole: right_area,
          tolerance: half_tolerance,
          depth: depth - 1
        )
      end
      private_class_method :recurse

      def simpson(left, right, f_left, f_midpoint, f_right)
        (right - left) * (f_left + (4.0 * f_midpoint) + f_right) / 6.0
      end
      private_class_method :simpson

      def finite_value!(value)
        numeric = Float(value)
        return numeric if numeric.finite?

        raise StatPower::DomainError, "integrand values must be finite"
      end
      private_class_method :finite_value!

      def validate_arguments!(left, right, tolerance, max_depth)
        unless left.finite? && right.finite? && left < right
          raise StatPower::DomainError, "integration bounds must be finite with lower < upper"
        end

        unless tolerance.finite? && tolerance.positive?
          raise StatPower::DomainError, "tolerance must be finite and positive"
        end

        return if max_depth.is_a?(Integer) && max_depth.positive?

        raise StatPower::DomainError, "max_depth must be a positive integer"
      end
      private_class_method :validate_arguments!
    end
  end
end
