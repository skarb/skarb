# Functions definitions and calls
# - :prototype -- function prototype
# - :defn -- function definition
# - :call -- function call
# - :args -- arguments' list, can be either abstract (on definition) or actual
#   (on call). If there are no arguments is should consist of :args only ("s(:args)").
module Emitter::Functions
  def emit_prototype(sexp)
    @out << sexp[1] << " " << sexp[2]
    in_parentheses { emit_abstract_args(sexp[3]) }
  end

  def emit_defn(sexp)
    @out << sexp[1] << " " << sexp[2]
    in_parentheses { emit_abstract_args(sexp[3]) }
    emit_generic_elem(sexp[4])
  end

  def emit_call(sexp)
    @out << sexp[1]
    in_parentheses { emit_actual_args(sexp[2]) }
  end

  private

  def emit_abstract_args(sexp)
    return if sexp.size <= 1
    sexp.middle.each do |x|
      emit_generic_elem(x)
      comma
    end
    emit_generic_elem(sexp.last)
  end

  def emit_actual_args(sexp)
    return if sexp.size <= 1

    sexp.middle(1,-1).each do |elem|
      emit_arg_expr(elem)
      comma
    end
    emit_arg_expr(sexp.last)
  end
end
