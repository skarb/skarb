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
