# Literals and vars
# - :lit -- literal
# - :str -- string literal
# - :var -- reference to variable
# - :decl -- variable declaration, two child nodes: type and name
module Emitter::Literals
  def emit_str(sexp)
    '"' + sexp[1] + '"'
  end

  def emit_lit(sexp)
    sexp[1].to_s
  end

  alias :emit_var :emit_lit

  def emit_decl(sexp)
    sexp[1,2].join ' '
  end
end
