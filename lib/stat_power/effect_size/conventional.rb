# frozen_string_literal: true

module StatPower
  module EffectSize
    # Cohen-style conventional effect-size lookup used by CRAN pwr.
    module Conventional
      VALUES = {
        p: { small: 0.2, medium: 0.5, large: 0.8 },
        t: { small: 0.2, medium: 0.5, large: 0.8 },
        chisq: { small: 0.1, medium: 0.3, large: 0.5 },
        r: { small: 0.1, medium: 0.3, large: 0.5 },
        anov: { small: 0.1, medium: 0.25, large: 0.4 },
        f2: { small: 0.02, medium: 0.15, large: 0.35 }
      }.freeze

      module_function

      # Resolve a conventional effect size.
      #
      # @param test [Symbol, String] pwr-style test family
      # @param size [Symbol, String] small, medium, or large
      # @return [Float]
      # @raise [StatPower::DomainError] for unknown tests or sizes
      def resolve(test:, size:)
        test_key = test.to_sym
        size_key = size.to_sym
        family = VALUES[test_key]

        raise StatPower::DomainError, "unknown effect-size test family: #{test}" unless family

        value = family[size_key]
        return value if value

        raise StatPower::DomainError, "unknown conventional effect size: #{size}"
      end
    end
  end
end
