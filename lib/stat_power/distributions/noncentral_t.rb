# frozen_string_literal: true

module StatPower
  module Distributions
    # Noncentral Student t distribution utilities.
    #
    # The CDF is evaluated from the defining normal/chi-square mixture using
    # adaptive quadrature on the logarithm of the chi-square variate.
    module NoncentralT
      LOG_WEIGHT_UNDERFLOW = -745.0

      module_function

      # Cumulative distribution function.
      #
      # @param x [Numeric] evaluation point
      # @param degrees_of_freedom [Numeric] positive degrees of freedom
      # @param noncentrality [Numeric] noncentrality parameter
      # @return [Float]
      def cdf(x, degrees_of_freedom:, noncentrality:)
        value = Float(x)
        df = normalize_degrees_of_freedom(degrees_of_freedom)
        delta = Float(noncentrality)
        validate_noncentrality!(delta)

        return StudentT.cdf(value, degrees_of_freedom: df) if delta.zero?
        return Normal.cdf(value - delta) if df.infinite?
        return Normal.cdf(-delta) if value.zero?

        shape = df / 2.0
        center = Math.log(df)
        half_width = [8.0, 30.0 * Math.sqrt(2.0 / df)].max
        log_normalizer = -(shape * Math.log(2.0)) - Math.lgamma(shape).first

        result = Integration::AdaptiveSimpson.integrate(
          lower: center - half_width,
          upper: center + half_width,
          tolerance: 1e-10,
          max_depth: 30
        ) do |log_variance|
          mixture_integrand(
            log_variance,
            value:,
            df:,
            delta:,
            shape:,
            log_normalizer:
          )
        end

        [[result, 0.0].max, 1.0].min
      end

      # Survival function P(T > x).
      #
      # Uses the identity P(T_delta > x) = F_{-delta}(-x).
      #
      # @param x [Numeric] evaluation point
      # @param degrees_of_freedom [Numeric] positive degrees of freedom
      # @param noncentrality [Numeric] noncentrality parameter
      # @return [Float]
      def survival(x, degrees_of_freedom:, noncentrality:)
        cdf(
          -Float(x),
          degrees_of_freedom:,
          noncentrality: -Float(noncentrality)
        )
      end

      def mixture_integrand(log_variance, value:, df:, delta:, shape:, log_normalizer:)
        variance = Math.exp(log_variance)
        log_weight = (shape * log_variance) -
                     (variance / 2.0) +
                     log_normalizer
        return 0.0 if log_weight < LOG_WEIGHT_UNDERFLOW

        conditional = Normal.cdf(
          (value * Math.sqrt(variance / df)) - delta
        )
        conditional * Math.exp(log_weight)
      end
      private_class_method :mixture_integrand

      def normalize_degrees_of_freedom(value)
        df = Float(value)
        return df if df.infinite? && df.positive?
        return df if df.finite? && df.positive?

        raise StatPower::DomainError, "degrees_of_freedom must be positive"
      rescue ArgumentError, TypeError
        raise StatPower::DomainError, "degrees_of_freedom must be numeric"
      end
      private_class_method :normalize_degrees_of_freedom

      def validate_noncentrality!(value)
        return if value.finite?

        raise StatPower::DomainError, "noncentrality must be finite"
      end
      private_class_method :validate_noncentrality!
    end
  end
end
