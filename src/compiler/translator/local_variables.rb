class Translator
  # A module consisting of functions which handle translation of nodes related
  # to local variables.
  module LocalVariables
    # Translate assignment to a local variable. The variable is declared unless
    # it already was. As a value of expression the variable is returned.
    def translate_lasgn(sexp)
      decl = s(:stmts)
      unless @symbol_table.has_lvar? sexp[1]
        @symbol_table.add_lvar sexp[1]
        decl = s(:decl, 'Fixnum*', sexp[1])
      end
      arg = translate_generic_sexp(sexp[2])
      @symbol_table.set_lvar_types sexp[1], arg.value_types
      filtered_stmts(decl, arg, s(:asgn, s(:var, sexp[1]), arg.value_symbol))
      .with_value(s(:var, sexp[1]), arg.value_types)
    end

    # Translate a referenced local variable to empty block with value of this
    # variable.
    def translate_lvar(sexp)
      unless @symbol_table.has_lvar? sexp[1]
        die 'Use of an uninitialized local variable'
      end
      s(:stmts).with_value(s(:var, sexp[1]), @symbol_table.get_lvar_types(sexp[1]))
    end
  end
end
