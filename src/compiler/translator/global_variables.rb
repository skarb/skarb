class Translator
  # A module consisting of functions which handle translation of nodes related
  # to global variables.
  #
  # Types of global variables are always unknown.
  module GlobalVariables
    # Translate assignment to a global variable. The variable is declared
    # unless it already was. As a value of expression the variable is returned.
    def translate_gasgn(sexp)
      var_name = mangle_gvar_name sexp[1]
      var_sexp = s(:var, var_name)
      @globals[var_name] = s(:decl, :'Object*', var_name)
      arg = translate_generic_sexp sexp[2]
      filtered_stmts(arg, s(:asgn, var_sexp, arg.value_sexp)).
        with_value_sexp var_sexp
    end

    # Translate a referenced global variable to empty block with value of this
    # variable.
    def translate_gvar(sexp)
      var_name = mangle_gvar_name sexp[1]
      s().with_value_sexp s(:var, var_name)
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
