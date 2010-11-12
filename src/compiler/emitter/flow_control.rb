require 'emitter/helpers'
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
  include Emitter::Helpers

  def emit_if(sexp)
    @out << 'if '
    in_parentheses { emit_arg_expr(sexp[1]) }
    newline
    emit_generic_elem(sexp[2])
    unless sexp[3].nil?
      @out << "else\n"
      emit_generic_elem(sexp[3])
    end
  end

  def emit_while(sexp)
    @out << 'while '
    in_parentheses { emit_arg_expr(sexp[1]) }
    newline
    emit_generic_elem(sexp[2])
    newline
  end

  def emit_do(sexp)
    @out << "do\n"
    emit_generic_elem(sexp[2])
    newline
    @out << 'while '
    in_parentheses { emit_arg_expr(sexp[1]) }
    @out << ";\n"
  end

  def emit_for(sexp)
    @out << 'for '
    in_parentheses do
      emit_generic_elem(sexp[1])
      semicolon_space
      emit_generic_elem(sexp[2])
      semicolon_space
      emit_generic_elem(sexp[3])
    end
    newline
    emit_generic_elem(sexp[4])
  end

  def emit_switch(sexp)
    @out << 'switch '
    in_parentheses { emit_generic_elem(sexp[1]) }
    newline
    emit_generic_elem(sexp[2])
  end

  def emit_default(sexp)
    @out << 'default: '
  end

  def emit_case(sexp)
    @out << "case "
    emit_generic_elem(sexp[1])
    colon_space
  end

  def emit_label(sexp)
    emit_generic_elem(sexp[1])
    colon_space
  end 

  alias :emit_continue :output_type_and_children
  alias :emit_break :output_type_and_children
  alias :emit_return :output_type_and_children
  alias :emit_goto :output_type_and_children
end
