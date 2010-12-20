class Translator
  # A module consisting of functions which handle translation of nodes related
  # to instance variables.
  #
  # Type of instance variable is always unknown.
  module InstanceVariables
    # Translate assignment to an instance variable. The variable is declared
    # unless it already was. As a value of expression the variable is returned.
    def translate_iasgn(sexp)
      str_name = sexp[1].to_s
      sname = str_name[1, str_name.length-1].to_sym
      unless @symbol_table.has_ivar? sexp[1]
        @symbol_table.add_ivar sexp[1]
      end
      arg = translate_generic_sexp(sexp[2])
      val_type = arg.value_type
      ivar_class = @symbol_table.get_ivar_class sexp[1]
      field_name =  s(:binary_oper, :'->',
                              s(:cast, ivar_class.star, s(:var, :self)),
                              s(:var, sname))
      filtered_stmts(arg, s(:asgn, field_name, arg.value_sexp))
      .with_value_sexp field_name
    end

    # Translate a referenced instance variable to empty block with value of this
    # variable.
    def translate_ivar(sexp)
      unless @symbol_table.has_ivar? sexp[1]
        @symbol_table.add_ivar sexp[1]
      end
      str_name = sexp[1].to_s
      sname = str_name[1, str_name.length-1].to_sym
      ivar_class = @symbol_table.get_ivar_class sexp[1]
      s(:stmts).with_value_sexp s(:binary_oper, :'->',
                                  s(:cast, ivar_class.star, s(:var, :self)),
          s(:var, sname))
    end
  end
end
