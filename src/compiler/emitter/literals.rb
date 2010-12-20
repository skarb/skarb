# Literals and vars
# - :lit -- literal
# - :str -- string literal
# - :var -- reference to variable
# - :decl -- variable declaration, two child nodes: type and name
module Emitter::Literals
  def Emitter.emit_str(sexp)
    '"' + sexp[1] + '"'
  end

  def Emitter.emit_lit(sexp)
    sexp[1].to_s
  end

  class << Emitter
    alias :emit_var :emit_lit
  end

  def Emitter.emit_decl(sexp)
    return emit_generic_elem(sexp[1]) + ' ' +sexp[2].to_s if sexp[1].class == Sexp
    sexp[1,2].join ' '
  end
end
