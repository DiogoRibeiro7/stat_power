# frozen_string_literal: true

module StatPower
  module Distributions
    # Utilities for the standard normal distribution.
    module Normal
      SQRT_TWO = Math.sqrt(2.0)
      INV_SQRT_TWO_PI = 1.0 / Math.sqrt(2.0 * Math::PI)

      A = [
        -3.969683028665376e+01,
        2.209460984245205e+02,
        -2.759285104469687e+02,
        1.383577518672690e+02,
        -3.066479806614716e+01,
        2.506628277459239e+00
      ].freeze

      B = [
        -5.447609879822406e+01,
        1.615858368580409e+02,
        -1.556989798598866e+02,
        6.680131188771972e+01,
        -1.328068155288572e+01
      ].freeze

      C = [
        -7.784894002430293e-03,
        -3.223964580411365e-01,
        -2.400758277161838e+00,
        -2.549732539343734e+00,
        4.374664141464968e+00,
        2.938163982698783e+00
      ].freeze

      D = [
        7.784695709041462e-03,
        3.224671290700398e-01,
        2.445134137142996e+00,
        3.754408661907416e+00
      ].freeze

      LOWER_TAIL = 0.02425
      UPPER_TAIL = 1.0 - LOWER_TAIL

      module_function

      # Probability density function of the standard normal distribution.
      #
      # @param x [Numeric] evaluation point
      # @return [Float] density at x
      def pdf(x)
        value = Float(x)
        INV_SQRT_TWO_PI * Math.exp(-0.5 * value * value)
      end

      # Cumulative distribution function of the standard normal distribution.
      #
      # Uses erfc rather than 1 + erf to avoid cancellation in the lower tail.
      #
      # @param x [Numeric] evaluation point
      # @return [Float] probability P(Z <= x)
      def cdf(x)
        value = Float(x)
        0.5 * Math.erfc(-value / SQRT_TWO)
      end

      # Survival function of the standard normal distribution.
      #
      # @param x [Numeric] evaluation point
      # @return [Float] probability P(Z > x)
      def survival(x)
        value = Float(x)
        0.5 * Math.erfc(value / SQRT_TWO)
      end

      # Quantile function of the standard normal distribution.
      #
      # Uses Peter J. Acklam's rational approximation. Boundary probabilities
      # map to the corresponding extended-real quantiles.
      #
      # @param probability [Numeric] probability in [0, 1]
      # @return [Float] z such that P(Z <= z) = probability
      # @raise [StatPower::DomainError] if probability is outside [0, 1]
      def quantile(probability)
        p = Float(probability)
        validate_probability!(p)

        return -Float::INFINITY if p.zero?
        return Float::INFINITY if p == 1.0

        if p < LOWER_TAIL
          lower_tail_quantile(p)
        elsif p > UPPER_TAIL
          -lower_tail_quantile(1.0 - p)
        else
          central_quantile(p)
        end
      end

      def validate_probability!(probability)
        return if probability.finite? && probability.between?(0.0, 1.0)

        raise StatPower::DomainError, "probability must be finite and lie in [0, 1]"
      end
      private_class_method :validate_probability!

      def lower_tail_quantile(probability)
        q = Math.sqrt(-2.0 * Math.log(probability))

        numerator = (((((C[0] * q) + C[1]) * q + C[2]) * q + C[3]) * q + C[4]) * q + C[5]
        denominator = ((((D[0] * q) + D[1]) * q + D[2]) * q + D[3]) * q + 1.0

        numerator / denominator
      end
      private_class_method :lower_tail_quantile

      def central_quantile(probability)
        q = probability - 0.5
        r = q * q

        numerator = (((((A[0] * r) + A[1]) * r + A[2]) * r + A[3]) * r + A[4]) * r + A[5]
        denominator = (((((B[0] * r) + B[1]) * r + B[2]) * r + B[3]) * r + B[4]) * r + 1.0

        q * numerator / denominator
      end
      private_class_method :central_quantile
    end
  end
end
