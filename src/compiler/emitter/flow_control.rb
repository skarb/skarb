# Flow control
# - :if -- three child nodes: condition (:arg_expr), block (:block), "else" block (:block)
# - :for -- four child nodes: init (:arg_expr), condition (:arg_expr),
#   assignment (:arg_expr), code (:block)
# - :while -- two child nodes: condition (:arg_expr), code (:block)
# - :do -- two child nodes: condition (:arg_expr), code (:block)
# - :switch -- two child nodes: expression (:arg_expr), code (:block)
# - :case
# - :goto
# - :label -- goto label
# - :break
# - :continue
# - :return
# - :default
module Emitter::FlowControl
  def emit_if(sexp)
    @out << "if ("
    emit_arg_expr(sexp[1])
    @out << ")\n"
    emit_generic_elem(sexp[2])
    unless sexp[3]==nil
      @out << "else\n"
      emit_generic_elem(sexp[3])
    end
  end

  def emit_while(sexp)
    @out << "while ("
    emit_arg_expr(sexp[1])
    @out << ")\n"
    emit_generic_elem(sexp[2])
    @out << "\n"
  end

  def emit_do(sexp)
    @out << "do\n"
    emit_generic_elem(sexp[2])
    @out << "\n"
    @out << "while ("
    emit_arg_expr(sexp[1])
    @out << ");\n"
  end

  def emit_for(sexp)
    @out << "for ("
    emit_generic_elem(sexp[1])
    @out << "; "
    emit_generic_elem(sexp[2])
    @out << "; "
    emit_generic_elem(sexp[3])
    @out << ")\n"
    emit_generic_elem(sexp[4])
  end

  def emit_switch(sexp)
    @out << "switch ("
    emit_generic_elem(sexp[1])
    @out << ")\n"
    emit_generic_elem(sexp[2])
  end

  def emit_default(sexp)
    @out << "default: "
  end

  def emit_case(sexp)
    @out << "case "
    emit_generic_elem(sexp[1])
    @out << ": "
  end

  def emit_label(sexp)
    emit_generic_elem(sexp[1])
    @out << ": "
  end 
end
