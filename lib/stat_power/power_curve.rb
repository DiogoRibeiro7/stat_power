# frozen_string_literal: true

module StatPower
  # Data-first power-curve generation.
  #
  # A caller supplies the sample sizes and a block that evaluates an existing
  # power solver at each sample size. The block may return either a numeric
  # power value or any result object exposing a +power+ reader.
  module PowerCurve
    module_function

    # Generate power-curve points.
    #
    # @param sample_sizes [Enumerable<Numeric>] sample sizes to evaluate
    # @yieldparam sample_size [Float] current sample size
    # @yieldreturn [Numeric, #power] achieved power or result object
    # @return [Array<StatPower::PowerCurvePoint>]
    def generate(sample_sizes:)
      unless block_given?
        raise StatPower::DomainError,
              "a block evaluating power at each sample size is required"
      end

      sizes = normalize_sample_sizes(sample_sizes)

      sizes.map do |sample_size|
        evaluated = yield(sample_size)
        power = extract_power(evaluated)

        PowerCurvePoint.new(
          sample_size:,
          power:
        )
      end
    end

    def normalize_sample_sizes(values)
      unless values.respond_to?(:map)
        raise StatPower::DomainError,
              "sample_sizes must be an enumerable collection"
      end

      sizes = values.map do |value|
        sample_size = Float(value)

        unless sample_size.finite? && sample_size.positive?
          raise StatPower::DomainError,
                "sample sizes must be finite and positive"
        end

        sample_size
      rescue ArgumentError, TypeError
        raise StatPower::DomainError,
              "sample sizes must be numeric"
      end

      if sizes.empty?
        raise StatPower::DomainError,
              "sample_sizes must contain at least one value"
      end

      sizes
    end
    private_class_method :normalize_sample_sizes

    def extract_power(value)
      power = if value.respond_to?(:power)
                value.power
              else
                Float(value)
              end

      power = Float(power)

      return power if power.finite? && power >= 0.0 && power <= 1.0

      raise StatPower::DomainError,
            "power evaluations must lie in [0, 1]"
    rescue ArgumentError, TypeError
      raise StatPower::DomainError,
            "power evaluations must be numeric or expose a numeric power value"
    end
    private_class_method :extract_power
  end
end
