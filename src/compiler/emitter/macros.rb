# Macro directives
# - :include
# - :define
module Emitter::Macros
  def emit_include(sexp)
    '#include ' + sexp[1] + "\n"
  end

  def emit_define(sexp)
    '#define ' + sexp[1] + "\n"
  end
end
