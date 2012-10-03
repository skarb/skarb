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
