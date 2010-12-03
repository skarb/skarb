class Translator
  # A module consisting of functions which handle translation of nodes related
  # to local variables.
  module LocalVariables
    # Translate assignment to a local variable. The variable is declared unless
    # it already was. As a value of expression the variable is returned.
    def translate_lasgn(sexp)
      decl = s(:stmts)
      arg = translate_generic_sexp(sexp[2])
      unless @symbol_table.has_lvar? sexp[1]
        @symbol_table.add_lvar sexp[1]
        # FIXME: It won't work. args.value_type.first isn't the best solution.
        decl = s(:decl, arg.value_type.first.to_s + '*', sexp[1])
      end
      @symbol_table.set_lvar_type sexp[1], arg.value_type
      filtered_stmts(decl, arg, s(:asgn, s(:var, sexp[1]), arg.value_sexp))
      .with_value(s(:var, sexp[1]), arg.value_type)
    end

    # Translate a referenced local variable to empty block with value of this
    # variable.
    def translate_lvar(sexp)
      unless @symbol_table.has_lvar? sexp[1]
        die "Use of an uninitialized local variable #{sexp[1]}"
      end
      s(:stmts).with_value(s(:var, sexp[1]), @symbol_table.get_lvar_type(sexp[1]))
    end
  end
end
