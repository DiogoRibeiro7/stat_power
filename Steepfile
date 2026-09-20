# frozen_string_literal: true

target :lib do
  signature "sig"

  check "lib"

  # `sig/` is the published public API contract rather than a full internal
  # typing of the library. Private helpers and internal constants are
  # deliberately left undeclared, so the three diagnostics that only report
  # missing internal declarations are disabled. Every other check, including
  # argument and return type mismatches against the declared public API, runs
  # at Steep's default strength.
  configure_code_diagnostics do |hash|
    hash[Steep::Diagnostic::Ruby::NoMethod] = nil
    hash[Steep::Diagnostic::Ruby::UnknownConstant] = nil
    hash[Steep::Diagnostic::Ruby::UndeclaredMethodDefinition] = nil
  end
end
