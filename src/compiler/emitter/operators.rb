# Operators
# - :binary_oper -- arithmetic, bitwise, logical, "." or "->" operator
# - :short_if -- "?:" operator
# - :l_unary_oper -- left "++", "--", "-", "!", "*", "&" operator
# - :r_unary_oper -- right "++", "--" operator
# - :indexer -- sexp in form: array_name [ index expr ]
module Emitter::Operators
  def Emitter.emit_short_if(sexp)
    emit_arg_expr(sexp[1]) + '?' + emit_arg_expr(sexp[2]) + ':' +
      emit_arg_expr(sexp[3])
  end

  def Emitter.emit_binary_oper(sexp)
    emit_arg_expr(sexp[2]) + sexp[1].to_s + emit_arg_expr(sexp[3])
  end

  def Emitter.emit_l_unary_oper(sexp)
    sexp[1].to_s + emit_arg_expr(sexp[2])
  end

  def Emitter.emit_r_unary_oper(sexp)
    emit_arg_expr(sexp[2]) + sexp[1].to_s
  end
  
  def Emitter.emit_indexer(sexp)
    emit_generic_elem(sexp[1]) + '[' + emit_arg_expr(sexp[2]) + ']'
  end

end
