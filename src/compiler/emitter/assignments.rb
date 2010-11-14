# Assignments
# - :asgn -- normal assignment
# - :aasgn -- "*=", "-=", "/=", "+="
module Emitter::Assignments
  def emit_asgn(sexp)
    emit_arg_expr(sexp[1])
    @out << '='
    emit_arg_expr(sexp[2])
  end

  def emit_aasgn(sexp)
    emit_arg_expr(sexp[2])
    @out << sexp[1]
    emit_arg_expr(sexp[3])
  end
end
