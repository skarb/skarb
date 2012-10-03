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
