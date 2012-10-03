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
