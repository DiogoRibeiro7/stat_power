# frozen_string_literal: true

require_relative "stat_power/version"
require_relative "stat_power/result"
require_relative "stat_power/power_result"
require_relative "stat_power/unequal_power_result"
require_relative "stat_power/errors"
require_relative "stat_power/special_functions/beta"
require_relative "stat_power/integration/adaptive_simpson"
require_relative "stat_power/distributions/normal"
require_relative "stat_power/distributions/student_t"
require_relative "stat_power/distributions/noncentral_t"
require_relative "stat_power/distributions/f_distribution"
require_relative "stat_power/distributions/noncentral_f"
require_relative "stat_power/solvers/bisection"
require_relative "stat_power/effect_size/conventional"
require_relative "stat_power/effect_size/proportion"
require_relative "stat_power/normal_mean"
require_relative "stat_power/proportion"
require_relative "stat_power/t_test"
require_relative "stat_power/t_test_unequal"
require_relative "stat_power/correlation"

module StatPower
end
