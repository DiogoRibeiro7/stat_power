# frozen_string_literal: true

module StatPower
  # Immutable container for a solved power-analysis quantity.
  Result = Data.define(:sample_size, :power, :effect_size, :alpha)
end
