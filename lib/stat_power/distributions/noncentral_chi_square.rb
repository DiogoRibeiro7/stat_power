# frozen_string_literal: true

module StatPower
  module Distributions
    # Noncentral chi-square distribution utilities.
    #
    # Probabilities are evaluated as a Poisson mixture of central chi-square
    # distributions with degrees of freedom increased by 2j.
    module NoncentralChiSquare
      MIXTURE_TOLERANCE = 1e-13
      MAX_MIXTURE_STEPS = 100_000

      module_function

      # Cumulative distribution function.
      #
      # @return [Float]
      def cdf(x, degrees_of_freedom:, noncentrality:)
        mixture_probability(
          x,
          degrees_of_freedom:,
          noncentrality:,
          tail: :cdf
        )
      end

      # Survival function P(X > x).
      #
      # @return [Float]
      def survival(x, degrees_of_freedom:, noncentrality:)
        mixture_probability(
          x,
          degrees_of_freedom:,
          noncentrality:,
          tail: :survival
        )
      end

      def mixture_probability(x, degrees_of_freedom:, noncentrality:, tail:)
        value = Float(x)
        df = normalize_degrees_of_freedom(degrees_of_freedom)
        lambda = normalize_noncentrality(noncentrality)
        raise StatPower::DomainError, "x must be finite" unless value.finite?

        return tail == :cdf ? 0.0 : 1.0 if value <= 0.0
        return central_probability(value, df, tail) if lambda.zero?

        poisson_mixture(
          value:,
          df:,
          poisson_mean: lambda / 2.0,
          tail:
        )
      end
      private_class_method :mixture_probability

      def poisson_mixture(value:, df:, poisson_mean:, tail:)
        mode = poisson_mean.floor.to_i
        mode_weight = Math.exp(
          -poisson_mean +
          (mode * Math.log(poisson_mean)) -
          Math.lgamma(mode + 1.0).first
        )

        total = mode_weight * central_probability(
          value,
          df + (2.0 * mode),
          tail
        )
        weight_sum = mode_weight

        lower_index = mode
        lower_weight = mode_weight
        upper_index = mode
        upper_weight = mode_weight

        1.upto(MAX_MIXTURE_STEPS) do
          lower_weight, lower_index, lower_term = lower_step(
            lower_weight,
            lower_index,
            poisson_mean,
            value,
            df,
            tail
          )
          upper_weight, upper_index, upper_term = upper_step(
            upper_weight,
            upper_index,
            poisson_mean,
            value,
            df,
            tail
          )

          total += lower_term + upper_term
          weight_sum += lower_weight + upper_weight

          break if mixture_converged?(weight_sum, lower_weight, upper_weight)
        end

        total.clamp(0.0, 1.0)
      end
      private_class_method :poisson_mixture

      def lower_step(weight, index, poisson_mean, value, df, tail)
        return [0.0, index, 0.0] if index.zero?

        next_weight = weight * index / poisson_mean
        next_index = index - 1
        term = next_weight * central_probability(
          value,
          df + (2.0 * next_index),
          tail
        )

        [next_weight, next_index, term]
      end
      private_class_method :lower_step

      def upper_step(weight, index, poisson_mean, value, df, tail)
        next_index = index + 1
        next_weight = weight * poisson_mean / next_index
        term = next_weight * central_probability(
          value,
          df + (2.0 * next_index),
          tail
        )

        [next_weight, next_index, term]
      end
      private_class_method :upper_step

      def central_probability(value, df, tail)
        if tail == :cdf
          ChiSquare.cdf(value, degrees_of_freedom: df)
        else
          ChiSquare.survival(value, degrees_of_freedom: df)
        end
      end
      private_class_method :central_probability

      def mixture_converged?(weight_sum, lower_weight, upper_weight)
        residual = (1.0 - weight_sum).abs
        residual <= MIXTURE_TOLERANCE &&
          lower_weight <= MIXTURE_TOLERANCE &&
          upper_weight <= MIXTURE_TOLERANCE
      end
      private_class_method :mixture_converged?

      def normalize_degrees_of_freedom(value)
        df = Float(value)
        return df if df.finite? && df.positive?

        raise StatPower::DomainError, "degrees_of_freedom must be finite and positive"
      rescue ArgumentError, TypeError
        raise StatPower::DomainError, "degrees_of_freedom must be numeric"
      end
      private_class_method :normalize_degrees_of_freedom

      def normalize_noncentrality(value)
        lambda = Float(value)
        return lambda if lambda.finite? && !lambda.negative?

        raise StatPower::DomainError, "noncentrality must be finite and non-negative"
      rescue ArgumentError, TypeError
        raise StatPower::DomainError, "noncentrality must be numeric"
      end
      private_class_method :normalize_noncentrality
    end
  end
end
