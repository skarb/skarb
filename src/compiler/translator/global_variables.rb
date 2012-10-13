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
