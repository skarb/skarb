# Operators
# - :binary_oper -- arithmetic, bitwise, logical, "." or "->" operator
# - :short_if -- "?:" operator
# - :l_unary_oper -- left "++", "--", "-", "!", "*", "&" operator
# - :r_unary_oper -- right "++", "--" operator
module Emitter::Operators
  def emit_short_if(sexp)
    emit_arg_expr(sexp[1])
    @out << '?'
    emit_arg_expr(sexp[2])
    colon
    emit_arg_expr(sexp[3])
  end

  def emit_binary_oper(sexp)
    emit_arg_expr(sexp[2])
    @out << sexp[1]
    emit_arg_expr(sexp[3])
  end

  def emit_l_unary_oper(sexp)
    @out << sexp[1]
    emit_arg_expr(sexp[2])
  end

  def emit_r_unary_oper(sexp)
    emit_arg_expr(sexp[2])
    @out << sexp[1]
  end
end
