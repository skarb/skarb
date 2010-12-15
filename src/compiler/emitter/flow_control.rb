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

  def Emitter.emit_if(sexp)
    'if(' + emit_arg_expr(sexp[1]) + ')' + emit_generic_elem(sexp[2]) +
      ('else' + emit_generic_elem(sexp[3]) unless sexp[3].nil?).to_s
  end

  def Emitter.emit_while(sexp)
    'while(' + emit_arg_expr(sexp[1]) + ')' + emit_generic_elem(sexp[2])
  end

  def Emitter.emit_do(sexp)
    'do' + emit_generic_elem(sexp[1]) + 'while(' + emit_arg_expr(sexp[2]) + ');'
  end

  def Emitter.emit_for(sexp)
    'for(' + emit_generic_elem(sexp[1]) + ';' + emit_generic_elem(sexp[2]) +
      ';' + emit_generic_elem(sexp[3]) + ')' + emit_generic_elem(sexp[4])
  end

  def Emitter.emit_switch(sexp)
    'switch(' + emit_generic_elem(sexp[1]) + ')' + emit_generic_elem(sexp[2])
  end

  def Emitter.emit_default(sexp)
    'default:'
  end

  def Emitter.emit_case(sexp)
    'case ' + emit_generic_elem(sexp[1]) + ':'
  end

  def Emitter.emit_label(sexp)
    "#{emit_generic_elem(sexp[1])}:"
  end

  class << Emitter
    alias :emit_continue :output_type_and_children
    alias :emit_break :output_type_and_children
    alias :emit_return :output_type_and_children
    alias :emit_goto :output_type_and_children
  end
end
