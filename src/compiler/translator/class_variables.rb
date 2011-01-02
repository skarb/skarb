class Translator
  # A module consisting of functions which handle translation of nodes related
  # to class variables.
  #
  # Types of class variables are always unknown.
  module ClassVariables
    # Translate assignment to a class variable. The variable is declared
    # unless it already was. As a value of expression the variable is returned.
    def translate_cvasgn(sexp)
      str_name = sexp[1].to_s
      sname = str_name[2, str_name.length-1].to_sym
      unless @symbol_table.has_cvar? sexp[1]
        @symbol_table.add_cvar sexp[1]
      end
      arg = translate_generic_sexp(sexp[2])
      val_type = arg.value_type
      cvar_class = @symbol_table.get_cvar_class sexp[1]
      field_name =  s(:binary_oper, :'.',
                              s(:var, ('vs_'+cvar_class.to_s).to_sym),
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
      str_name = sexp[1].to_s
      sname = str_name[2, str_name.length-1].to_sym
      cvar_class = @symbol_table.get_cvar_class sexp[1]
      s(:stmts).with_value_sexp s(:binary_oper, :'.',
                                  s(:var, ('vs_'+cvar_class.to_s).to_sym),
                                  s(:var, sname))
    end
  end
end
