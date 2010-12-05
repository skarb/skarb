class Translator
  # A module consisting of functions which handle translation of nodes related
  # to instance variables.
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
      @symbol_table.set_ivar_type sexp[1], arg.value_type
      field_name =  s(:binary_oper, :'->',
                              s(:cast, @symbol_table.cclass.star, s(:var, :self)),
                              s(:var, sname))
      filtered_stmts(arg, s(:asgn, field_name, arg.value_sexp))
      .with_value(field_name, arg.value_type)
    end

    # Translate a referenced instance variable to empty block with value of this
    # variable.
    def translate_ivar(sexp)
      unless @symbol_table.has_ivar? sexp[1]
        die 'Use of uninitialized instance variable'
      end
      str_name = sexp[1].to_s
      sname = str_name[1, str_name.length-1].to_sym
      s(:stmts).with_value(
        s(:binary_oper, :'->', s(:cast, @symbol_table.cclass.star, s(:var, :self)),
          s(:var, sname)),
        @symbol_table.get_ivar_type(sexp[1]))
    end
  end
end
