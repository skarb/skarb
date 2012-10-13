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
    if sexp[1].is_a? Symbol
      sexp[1].to_s
    else
      emit_generic_elem(sexp[1])
    end + '(' + emit_actual_args(sexp[2]) + ')'
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
