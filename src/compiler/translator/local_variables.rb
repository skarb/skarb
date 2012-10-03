class Translator
  # A module consisting of functions which handle translation of nodes related
  # to local variables.
  module LocalVariables
    # Translate assignment to a local variable. The variable is declared unless
    # it already was. As a value of expression the variable is returned.
    def translate_lasgn(sexp)
      arg = translate_generic_sexp(sexp[2])
      var_name = mangle_lvar_name sexp[1]
      unless @symbol_table.has_lvar? sexp[1]
        @symbol_table.add_lvar sexp[1]
      end
      val_type = arg.value_type
      @symbol_table.set_lvar_type sexp[1], val_type 
      filtered_stmts(arg, s(:asgn, s(:var, var_name), arg.value_sexp))
      .with_value(s(:var, var_name), arg.value_type)
    end

    # Translate a referenced local variable to empty block with value of this
    # variable.
    def translate_lvar(sexp)
      var_name = mangle_lvar_name sexp[1]
      unless @symbol_table.has_lvar? sexp[1]
        @symbol_table.add_lvar sexp[1]
      end
      s(:stmts).with_value(s(:var, var_name), @symbol_table.get_lvar_type(sexp[1]))
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
