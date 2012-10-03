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

##################################################################################
# (C) 2010-2012 Jan Stępień, Julian Zubek
# 
# This file is a part of Skarb -- Ruby to C compiler.
# 
# Skarb is free software: you can redistribute it and/or modify it under the terms
# of the GNU Lesser General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later
# version.
# 
# Skarb is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
# PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
# 
# You should have received a copy of the GNU Lesser General Public License along
# with Skarb. If not, see <http://www.gnu.org/licenses/>.
# 
##################################################################################
