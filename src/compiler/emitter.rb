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

require 'stringio'
require 'extensions'

# Generates code from given C abstract syntax tree. It does
# not perform any validation.
class Emitter
  def Emitter.emit(sexp)
    emit_generic_elem(sexp)
  end

  private

  %w{assignments blocks flow_control functions literals macros operators helpers
    modifiers composite errors
  }.each do |file|
    require 'emitter/' + file
  end

  include Assignments
  include Blocks
  include FlowControl
  include Functions
  include Literals
  include Macros
  include Operators
  include Modifiers
  include Composite
  include Errors

  def Emitter.emit_cast(sexp)
    '((' + sexp[1].to_s + ')' + emit_arg_expr(sexp[2]) + ')'
  end

  # Universal function for emitting any argument expression
  # with correct parenthesis
  def Emitter.emit_arg_expr(elem)
    case elem[0]
    when :str, :lit, :var, :decl, :init_block
      emit_generic_elem(elem)
    else
      '(' + emit_generic_elem(elem) + ')'
    end
  end

  # Emits a symbol or executes a "emit_..." method according to the sexp[0]
  # symbol.
  def Emitter.emit_generic_elem(sexp)
    if sexp.is_a? Symbol
      sexp.to_s
    elsif sexp.is_a? Sexp
      begin
        Emitter.send 'emit_' + sexp[0].to_s, sexp
      rescue NoMethodError
        p sexp
        raise UnexpectedSexpError.new sexp[0]
      end
    end
  end
end
