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
