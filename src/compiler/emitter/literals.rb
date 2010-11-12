# Literals and vars
# - :lit -- literal
# - :str -- string literal
# - :var -- reference to variable
# - :decl -- variable declaration, two child nodes: type and name
module Emitter::Literals
  def emit_str(sexp)
    output_with_double_quotes sexp[1]
  end

  def emit_lit(sexp)
    @out << sexp[1]
  end

  def emit_var(sexp)
    @out << sexp[1]
  end

  def emit_decl(sexp)
    @out << sexp[1] << " " << sexp[2]
  end
end
