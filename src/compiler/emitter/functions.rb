# Functions definitions and calls
# - :prototype -- function prototype
# - :defn -- function definition
# - :call -- function call
# - :args -- arguments' list, can be either abstract (on definition) or actual
#   (on call). If there are no arguments is should consist of :args only ("s(:args)").
module Emitter::Functions
  def Emitter.emit_prototype(sexp)
    sexp[1,2].join(' ') + '(' + emit_abstract_args(sexp[3]) + ')'
  end

  def Emitter.emit_defn(sexp)
    sexp[1].to_s + ' ' + sexp[2].to_s +
      '(' + emit_abstract_args(sexp[3]) + ')' + emit_generic_elem(sexp[4])
  end

  def Emitter.emit_call(sexp)
    sexp[1].to_s + '(' + emit_actual_args(sexp[2]) + ')'
  end

  private

  def Emitter.emit_abstract_args(sexp)
    return '' if sexp.size <= 1
    sexp.middle.map { |x| emit_generic_elem(x) + ',' }.join() +
      emit_generic_elem(sexp.last)
  end

  def Emitter.emit_actual_args(sexp)
    return '' if sexp.size <= 1
    sexp.middle(1,-1).map { |elem| emit_arg_expr(elem) + ',' }.join() +
      emit_arg_expr(sexp.last)
  end
end
