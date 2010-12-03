class Translator
  # A module consisting of functions which emit type checking expressions.
  module TypeChecks
    # Packs some code in an if clause which do simple type check at runtime.
    def add_simple_type_check(variable_symbol, type_symbol, body)
      var = next_var_name
      cond = s(:binary_oper, :==, s(:binary_oper, :'->',
                                    s(:var, variable_symbol), s(:var, :type)),
                                    s(:lit, @symbol_table[type_symbol][:id]))
      if_true = translate_generic_sexp body
      filtered_stmts(
        s(:decl, :int, var), # :TODO: Change int
        s(:if, cond,
          filtered_block(if_true, s(:asgn, s(:var, var), if_true.value_sexp)))
      ).with_value_sexp s(:var, var)
    end

    # Performs complex type check at runtime through switch clause.
    def add_complex_type_check(variable_symbol, type2code_hash)
      var = next_var_name
      type_expr = s(:binary_oper, :'->', s(:var, variable_symbol),
                    s(:var, :type))
      case_blocks = []
      type2code_hash.each_pair do |key, val|
        code = translate_generic_sexp val
        case_blocks << s(:case,
                         s(:lit, @symbol_table[key][:id])) << filtered_stmts(code,
                         s(:asgn, s(:var, var), code.value_sexp)) << s(:break)
      end

      filtered_stmts(
        s(:decl, :int, var), # :TODO: Change int
        s(:switch, type_expr,
          filtered_block(*case_blocks))).with_value_sexp s(:var, var)
    end
  end
end
