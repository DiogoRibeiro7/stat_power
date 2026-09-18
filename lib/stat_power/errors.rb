# frozen_string_literal: true

module StatPower
  # Base error class for stat_power.
  class Error < StandardError; end

  # Raised when a numerical or statistical argument lies outside its domain.
  class DomainError < Error; end

  # Raised when an iterative numerical method fails to converge.
  class ConvergenceError < Error; end
end
