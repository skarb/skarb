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

# Operators
# - :binary_oper -- arithmetic, bitwise, logical, "." or "->" operator
# - :short_if -- "?:" operator
# - :l_unary_oper -- left "++", "--", "-", "!", "*", "&" operator
# - :r_unary_oper -- right "++", "--" operator
# - :indexer -- sexp in form: array_name [ index expr ]
module Emitter::Operators
  def Emitter.emit_short_if(sexp)
    emit_arg_expr(sexp[1]) + '?' + emit_arg_expr(sexp[2]) + ':' +
      emit_arg_expr(sexp[3])
  end

  def Emitter.emit_binary_oper(sexp)
    emit_arg_expr(sexp[2]) + sexp[1].to_s + emit_arg_expr(sexp[3])
  end

  def Emitter.emit_l_unary_oper(sexp)
    sexp[1].to_s + emit_arg_expr(sexp[2])
  end

  def Emitter.emit_r_unary_oper(sexp)
    emit_arg_expr(sexp[2]) + sexp[1].to_s
  end
  
  def Emitter.emit_indexer(sexp)
    emit_generic_elem(sexp[1]) + '[' + emit_arg_expr(sexp[2]) + ']'
  end

end
