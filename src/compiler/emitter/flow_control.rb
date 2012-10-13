# Copyright (c) 2010-2012 Jan Stępień, Julian Zubek
#
# This file is a part of Skarb -- a Ruby to C compiler.
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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
