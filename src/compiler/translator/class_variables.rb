class Translator
  # A module consisting of functions which handle translation of nodes related
  # to class variables.
  #
  # Types of class variables are always unknown.
  module ClassVariables
    # Translate assignment to a class variable. The variable is declared
    # unless it already was. As a value of expression the variable is returned.
    def translate_cvasgn(sexp)
      sname = mangle_cvar_name sexp[1]
      unless @symbol_table.has_cvar? sexp[1]
        @symbol_table.add_cvar sexp[1]
      end
      arg = translate_generic_sexp(sexp[2])
      val_type = arg.value_type
      cvar_class = @symbol_table.get_cvar_class sexp[1]
      cvars_struct_var = mangle_cvars_struct_var_name cvar_class
      field_name =  s(:binary_oper, :'.',
                              s(:var, cvars_struct_var),
                              s(:var, sname))
      filtered_stmts(arg, s(:asgn, field_name, arg.value_sexp))
      .with_value_sexp field_name
    end

    alias :translate_cvdecl :translate_cvasgn

    # Translate a referenced class variable to empty block with value of this
    # variable.
    def translate_cvar(sexp)
      unless @symbol_table.has_cvar? sexp[1]
        @symbol_table.add_cvar sexp[1]
      end
      sname = mangle_cvar_name sexp[1]
      cvar_class = @symbol_table.get_cvar_class sexp[1]
      cvars_struct_var = mangle_cvars_struct_var_name cvar_class
      s(:stmts).with_value_sexp s(:binary_oper, :'.',
                                  s(:var, cvars_struct_var),
                                  s(:var, sname))
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
