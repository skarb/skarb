# Assignments
# - :asgn -- normal assignment
# - :aasgn -- "*=", "-=", "/=", "+="
module Emitter::Assignments
  def Emitter.emit_asgn(sexp)
    emit_arg_expr(sexp[1]) + '=' + emit_arg_expr(sexp[2])
  end

  def Emitter.emit_aasgn(sexp)
    emit_arg_expr(sexp[2]) + sexp[1] + emit_arg_expr(sexp[3])
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
