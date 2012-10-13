# Copyright (c) 2010-2012 Jan Stępień, Julian Zubek
#
# This file is a part of Skarb -- a Ruby to C compiler.
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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
