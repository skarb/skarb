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

# Literals and vars
# - :lit -- literal
# - :str -- string literal
# - :var -- reference to variable
# - :decl -- variable declaration, two child nodes: type and name
module Emitter::Literals
  def Emitter.emit_str(sexp)
    '"' + sexp[1] + '"'
  end

  def Emitter.emit_lit(sexp)
    sexp[1].to_s
  end

  class << Emitter
    alias :emit_var :emit_lit
  end

  def Emitter.emit_decl(sexp)
    return emit_generic_elem(sexp[1]) + ' ' +sexp[2].to_s if sexp[1].class == Sexp
    sexp[1,2].join ' '
  end
end
