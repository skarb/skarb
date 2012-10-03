require 'sexp_processor'

# Pair containing Ruby sexps and it translated C equivalent.
SexpPair = Struct.new(:ruby_sexp, :c_sexp)

# This class registers relation between parts of original Ruby AST and its translated
# C equivalent. Such knowledge is necessary for further optimisations. Dictionary is
# indexed by Ruby sexp types. Each entry is an array containing pairs of sexps
# (SexpPair).
class TranslatedSexpDictionary < Hash

   def add_entry(ruby_sexp, c_sexp)
     (self[ruby_sexp.first] ||= []).push SexpPair.new(ruby_sexp, c_sexp)
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
