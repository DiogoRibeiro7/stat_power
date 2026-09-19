# frozen_string_literal: true

module StatPower
  module EffectSize
    # Effect-size utilities for proportions.
    module Proportion
      module_function

      # Compute Cohen's h for two proportions.
      #
      # h = 2 asin(sqrt(p1)) - 2 asin(sqrt(p2))
      #
      # @param p1 [Numeric] first proportion in [0, 1]
      # @param p2 [Numeric] second proportion in [0, 1]
      # @return [Float] signed Cohen h
      # @raise [StatPower::DomainError] if either proportion is outside [0, 1]
      def cohen_h(p1:, p2:)
        first = probability!(p1, "p1")
        second = probability!(p2, "p2")

        (2.0 * Math.asin(Math.sqrt(first))) -
          (2.0 * Math.asin(Math.sqrt(second)))
      end

      def probability!(value, name)
        probability = Float(value)
        return probability if probability.finite? && probability.between?(0.0, 1.0)

        raise StatPower::DomainError, "#{name} must be finite and lie in [0, 1]"
      rescue ArgumentError, TypeError
        raise StatPower::DomainError, "#{name} must be numeric"
      end
      private_class_method :probability!
    end
  end
end
