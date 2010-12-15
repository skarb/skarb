# Macro directives
# - :include
# - :define
module Emitter::Macros
  def Emitter.emit_include(sexp)
    '#include ' + sexp[1] + "\n"
  end

  def Emitter.emit_define(sexp)
    '#define ' + sexp[1] + "\n"
  end
end
