# frozen_string_literal: true

module StatPower
  module Distributions
    # Noncentral Fisher-Snedecor F distribution utilities.
    #
    # The CDF and survival function are evaluated with the standard Poisson
    # mixture of regularized incomplete-beta probabilities.
    module NoncentralF
      MIXTURE_TOLERANCE = 1e-13
      MAX_MIXTURE_STEPS = 100_000

      module_function

      # Cumulative distribution function.
      #
      # @return [Float]
      def cdf(x, numerator_df:, denominator_df:, noncentrality:)
        mixture_probability(
          x,
          numerator_df:,
          denominator_df:,
          noncentrality:,
          tail: :cdf
        )
      end

      # Survival function P(F > x).
      #
      # @return [Float]
      def survival(x, numerator_df:, denominator_df:, noncentrality:)
        mixture_probability(
          x,
          numerator_df:,
          denominator_df:,
          noncentrality:,
          tail: :survival
        )
      end

      def mixture_probability(x, numerator_df:, denominator_df:, noncentrality:, tail:)
        value = Float(x)
        numerator = normalize_df(numerator_df, "numerator_df")
        denominator = normalize_df(denominator_df, "denominator_df")
        lambda = normalize_noncentrality(noncentrality)
        raise StatPower::DomainError, "x must be finite" unless value.finite?

        return boundary_probability(value, tail) if value <= 0.0
        return central_probability(value, numerator, denominator, tail) if lambda.zero?

        transformed = numerator * value / ((numerator * value) + denominator)
        poisson_mean = lambda / 2.0
        shape_a = numerator / 2.0
        shape_b = denominator / 2.0

        poisson_beta_mixture(
          poisson_mean:,
          transformed:,
          shape_a:,
          shape_b:,
          tail:
        )
      end
      private_class_method :mixture_probability

      def poisson_beta_mixture(poisson_mean:, transformed:, shape_a:, shape_b:, tail:)
        mode = poisson_mean.floor.to_i
        mode_weight = Math.exp(
          -poisson_mean +
          (mode * Math.log(poisson_mean)) -
          Math.lgamma(mode + 1.0).first
        )

        total = mode_weight * beta_term(
          transformed,
          shape_a + mode,
          shape_b,
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
            transformed,
            shape_a,
            shape_b,
            tail
          )
          upper_weight, upper_index, upper_term = upper_step(
            upper_weight,
            upper_index,
            poisson_mean,
            transformed,
            shape_a,
            shape_b,
            tail
          )

          total += lower_term + upper_term
          weight_sum += lower_weight + upper_weight

          break if mixture_converged?(weight_sum, lower_weight, upper_weight)
        end

        [[total, 0.0].max, 1.0].min
      end
      private_class_method :poisson_beta_mixture

      def lower_step(weight, index, poisson_mean, transformed, shape_a, shape_b, tail)
        return [0.0, index, 0.0] if index.zero?

        next_weight = weight * index / poisson_mean
        next_index = index - 1
        term = next_weight * beta_term(
          transformed,
          shape_a + next_index,
          shape_b,
          tail
        )

        [next_weight, next_index, term]
      end
      private_class_method :lower_step

      def upper_step(weight, index, poisson_mean, transformed, shape_a, shape_b, tail)
        next_index = index + 1
        next_weight = weight * poisson_mean / next_index
        term = next_weight * beta_term(
          transformed,
          shape_a + next_index,
          shape_b,
          tail
        )

        [next_weight, next_index, term]
      end
      private_class_method :upper_step

      def beta_term(transformed, shape_a, shape_b, tail)
        if tail == :cdf
          SpecialFunctions::Beta.regularized(
            transformed,
            a: shape_a,
            b: shape_b
          )
        else
          SpecialFunctions::Beta.regularized(
            1.0 - transformed,
            a: shape_b,
            b: shape_a
          )
        end
      end
      private_class_method :beta_term

      def mixture_converged?(weight_sum, lower_weight, upper_weight)
        residual = (1.0 - weight_sum).abs
        residual <= MIXTURE_TOLERANCE &&
          lower_weight <= MIXTURE_TOLERANCE &&
          upper_weight <= MIXTURE_TOLERANCE
      end
      private_class_method :mixture_converged?

      def boundary_probability(value, tail)
        return tail == :cdf ? 0.0 : 1.0 if value <= 0.0

        raise StatPower::DomainError, "unreachable boundary state"
      end
      private_class_method :boundary_probability

      def central_probability(value, numerator, denominator, tail)
        if tail == :cdf
          FDistribution.cdf(
            value,
            numerator_df: numerator,
            denominator_df: denominator
          )
        else
          FDistribution.survival(
            value,
            numerator_df: numerator,
            denominator_df: denominator
          )
        end
      end
      private_class_method :central_probability

      def normalize_df(value, name)
        degrees = Float(value)
        return degrees if degrees.finite? && degrees.positive?

        raise StatPower::DomainError, "#{name} must be finite and positive"
      rescue ArgumentError, TypeError
        raise StatPower::DomainError, "#{name} must be numeric"
      end
      private_class_method :normalize_df

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
