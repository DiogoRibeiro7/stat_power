# frozen_string_literal: true

module StatPower
  # Immutable point on a statistical power curve.
  PowerCurvePoint = Data.define(:sample_size, :power)
end
