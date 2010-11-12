# Functions definitions and calls
# - :prototype -- function prototype
# - :defn -- function definition
# - :call -- function call
# - :abstract_args -- abstract parameters list
# - :actual_args -- actual parameters list
module Emitter::Functions
  def emit_prototype(sexp)
    @out << sexp[1] << " " << sexp[2] << " ("
    emit_abstract_args(sexp[3])
    @out << ")"
  end

  def emit_abstract_args(sexp)
    sexp.middle.each do |x|
      emit_generic_elem(x)
      @out << ", "
    end
    if sexp.last!=nil
      emit_generic_elem(sexp.last)
    end
  end

  def emit_defn(sexp)
    @out << sexp[1] << " " << sexp[2] << "("
    emit_abstract_args(sexp[3])
    @out << ")\n"
    emit_generic_elem(sexp[4])
  end

  def emit_actual_args(sexp)
    return if sexp.last == nil

    sexp.middle(1,-1).each do |elem|
      emit_arg_expr(elem)
      @out << ", "
    end
    emit_arg_expr(sexp.last)
  end

  def emit_call(sexp)
    @out << sexp[1] << "("
    emit_actual_args(sexp[2])
    @out << ")"
  end
end
