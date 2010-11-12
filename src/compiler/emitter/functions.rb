# Functions definitions and calls
# - :prototype -- function prototype
# - :defn -- function definition
# - :call -- function call
# - :abstract_args -- abstract parameters list
# - :actual_args -- actual parameters list
module Emitter::Functions
  def emit_prototype(sexp)
    @out << sexp[1]
    output_with_spaces sexp[2]
    in_parentheses { emit_abstract_args(sexp[3]) }
  end

  def emit_abstract_args(sexp)
    sexp.middle.each do |x|
      emit_generic_elem(x)
      comma_space
    end
    emit_generic_elem(sexp.last) unless sexp.last.nil?
  end

  def emit_defn(sexp)
    @out << sexp[1] << " " << sexp[2]
    in_parentheses { emit_abstract_args(sexp[3]) }
    newline
    emit_generic_elem(sexp[4])
  end

  def emit_actual_args(sexp)
    return if sexp.last.nil?

    sexp.middle(1,-1).each do |elem|
      emit_arg_expr(elem)
      comma_space
    end
    emit_arg_expr(sexp.last)
  end

  def emit_call(sexp)
    @out << sexp[1]
    in_parentheses { emit_actual_args(sexp[2]) }
  end
end
