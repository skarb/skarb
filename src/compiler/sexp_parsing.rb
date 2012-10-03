require 'sexp_processor'

# Functions that help extracting specific elements from sexps.
module SexpParsing
  
   def lasgn_get_var(sexp)
      sexp[1]
   end
 
   def lasgn_get_right(sexp)
      sexp[2]
   end

   alias :iasgn_get_var :lasgn_get_var
   alias :cvdecl_get_var :lasgn_get_var
   
   alias :iasgn_get_right :lasgn_get_right
   alias :cvdecl_get_right :lasgn_get_right

   alias :return_get_right :lasgn_get_var
   
   def call_get_object(sexp)
      sexp[1]
   end

   def call_get_method(sexp)
      sexp[2]
   end

   def call_get_args(sexp)
      sexp[3].drop(1)
   end

   def defn_get_args(sexp)
      sexp[2].drop(1)
   end

   def translated_fun_name(c_sexp)
      c_sexp.last.last[1]
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
