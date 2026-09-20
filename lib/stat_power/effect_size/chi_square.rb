# frozen_string_literal: true

module StatPower
  module EffectSize
    # Cohen's w effect-size utilities for chi-square tests.
    module ChiSquare
      SUM_TOLERANCE = 1e-10

      module_function

      # Cohen's w for a goodness-of-fit chi-square test.
      #
      # @param null_probabilities [Array<Numeric>] probabilities under H0
      # @param alternative_probabilities [Array<Numeric>] probabilities under H1
      # @return [Float]
      def goodness_of_fit(null_probabilities:, alternative_probabilities:)
        null_values = probability_vector!(null_probabilities, "null_probabilities")
        alternative_values = probability_vector!(
          alternative_probabilities,
          "alternative_probabilities"
        )

        unless null_values.length == alternative_values.length
          raise StatPower::DomainError,
                "probability vectors must have the same length"
        end

        if null_values.any?(&:zero?)
          raise StatPower::DomainError,
                "null probabilities must be strictly positive"
        end

        sum = null_values.zip(alternative_values).sum do |null_value, alternative_value|
          difference = alternative_value - null_value
          (difference * difference) / null_value
        end

        Math.sqrt(sum)
      end

      # Cohen's w for a chi-square test of association.
      #
      # @param probabilities [Array<Array<Numeric>>] two-way probability table
      # @return [Float]
      def association(probabilities:)
        table = probability_table!(probabilities)
        row_totals = table.map(&:sum)
        column_totals = table.transpose.map(&:sum)

        if row_totals.any?(&:zero?) || column_totals.any?(&:zero?)
          raise StatPower::DomainError,
                "all row and column marginal probabilities must be positive"
        end

        sum = table.each_with_index.sum do |row, row_index|
          row.each_with_index.sum do |observed, column_index|
            expected = row_totals[row_index] * column_totals[column_index]
            difference = observed - expected
            (difference * difference) / expected
          end
        end

        Math.sqrt(sum)
      end

      def probability_vector!(values, name)
        unless values.is_a?(Array) && values.length >= 2
          raise StatPower::DomainError, "#{name} must contain at least two probabilities"
        end

        normalized = values.map { |value| probability!(value, name) }
        validate_probability_sum!(normalized.sum, name)
        normalized
      end
      private_class_method :probability_vector!

      def probability_table!(values)
        unless values.is_a?(Array) && values.length >= 2 &&
               values.all? { |row| row.is_a?(Array) }
          raise StatPower::DomainError,
                "probabilities must be a two-dimensional table"
        end

        column_count = values.first.length
        unless column_count >= 2 && values.all? { |row| row.length == column_count }
          raise StatPower::DomainError,
                "probability table must be rectangular with at least two columns"
        end

        table = values.map do |row|
          row.map { |value| probability!(value, "probabilities") }
        end
        validate_probability_sum!(table.flatten.sum, "probabilities")
        table
      end
      private_class_method :probability_table!

      def probability!(value, name)
        probability = Float(value)
        return probability if probability.finite? &&
                              probability >= 0.0 &&
                              probability <= 1.0

        raise StatPower::DomainError, "#{name} must contain probabilities in [0, 1]"
      rescue ArgumentError, TypeError
        raise StatPower::DomainError, "#{name} must contain numeric probabilities"
      end
      private_class_method :probability!

      def validate_probability_sum!(sum, name)
        return if (sum - 1.0).abs <= SUM_TOLERANCE

        raise StatPower::DomainError, "#{name} must sum to 1"
      end
      private_class_method :validate_probability_sum!
    end
  end
end
