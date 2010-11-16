# Macro directives
# - :include
# - :define
module Emitter::Macros
  def emit_include(sexp)
    @out << "#include " << sexp[1] << "\n"
  end

  def emit_define(sexp)
    @out << "#define " << sexp[1] << "\n"
  end
end
