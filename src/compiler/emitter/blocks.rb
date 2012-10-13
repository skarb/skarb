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

# Blocks
# - :block -- "{" + statement + ";" + ... + "}"
# - :init_block -- "{" + value + "," + ... + "}"
module Emitter::Blocks
  def Emitter.emit_file(sexp)
    sexp.rest.map do |elem|
      emit_generic_elem(elem) + (';' if needs_semicolon? elem).to_s
    end.join
  end

  def Emitter.emit_block(sexp)
    # Don't emit anything after a return statement.
    if indx = sexp.index { |child| child.is_a? Sexp and child.first == :return }
      sexp = sexp[0..indx]
    end
    '{' + sexp.rest.map { |elem| emit_generic_elem(elem) + ';' }.join + '}'
  end

  def Emitter.emit_init_block(sexp)
    return '{}' if sexp.length == 1
    '{' + sexp.rest.map { |elem| emit_generic_elem(elem) }.join(',') + '}'
  end

  private

  def Emitter.needs_semicolon?(sexp)
    not [:define, :include, :defn].include? sexp[0]
  end
end

