class Translator
  # A module consisting of functions which handle translation of nodes related
  # to global variables.
  #
  # Types of global variables are always unknown.
  module GlobalVariables
    # Translate assignment to a global variable. The variable is declared
    # unless it already was. As a value of expression the variable is returned.
    def translate_gasgn(sexp)
      sname = sexp[1].to_s
      var_name = ('g_'+sname[1..sname.length-1]).to_sym
      var_sexp = s(:var, var_name)
      @globals[var_name] = s(:decl, :'Object*', var_name)
      arg = translate_generic_sexp sexp[2]
      filtered_stmts(arg, s(:asgn, var_sexp, arg.value_sexp)).
        with_value_sexp var_sexp
    end

    # Translate a referenced global variable to empty block with value of this
    # variable.
    def translate_gvar(sexp)
      sname = sexp[1].to_s
      var_name = ('g_'+sname[1..sname.length-1]).to_sym
      s().with_value_sexp s(:var, var_name)
    end
  end
end
