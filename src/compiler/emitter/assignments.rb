# Assignments
# - :asgn -- normal assignment
# - :aasgn -- "*=", "-=", "/=", "+="
module Emitter::Assignments
  def Emitter.emit_asgn(sexp)
    emit_arg_expr(sexp[1]) + '=' + emit_arg_expr(sexp[2])
  end

  def Emitter.emit_aasgn(sexp)
    emit_arg_expr(sexp[2]) + sexp[1] + emit_arg_expr(sexp[3])
  end
end
