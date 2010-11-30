class Translator
  # A module consisting of functions which handle translation of nodes related
  # to defining and calling functions and methods.
  module Functions
    # Translates a call to the Kernel#puts method or a simple function defined
    # previously. All other calls cause an error. TODO: split it into multiple
    # methods.
    def translate_call(sexp)
      # Only simple functions without arguments are supported.
      raise UnsupportedNodeError unless sexp[1].nil? or sexp[3].count > 1
      var = next_var_name
      args_evaluation = s(:stmts)
      call_arguments = s(:args)
      if sexp[2] == :puts
        call = faked_puts sexp
      elsif defn = @functions_definitions[sexp[2]]
        # If the function has been already defined translate it's body and save
        # the output in @functions_implementations.
        unless @functions_implementations.has_key? defn[1]
          @symbol_table.cfunction = defn[1]
          defn_args = s(:args)
          call_args_eval_stmts = []
          call_arg_number = 1
          defn[2].drop(1).each do |arg|
            @symbol_table.add_lvar arg
            # FIXME: set the actual type
            @symbol_table.set_lvar_types arg, [Fixnum]
            defn_args << s(:decl, 'Fixnum*', arg)
            args_evaluation << translate_generic_sexp(sexp[3][call_arg_number])
            call_arguments << args_evaluation.last.value_symbol
            call_arg_number += 1
          end
          args_evaluation = filtered_stmts(*args_evaluation.rest)
          body = translate_generic_sexp(defn[3][1])
          body_block = filtered_block(body, s(:return, body.value_symbol))
          # FIXME: set the actual return type
          @functions_implementations[defn[1]] = s(:defn, 'Fixnum*', defn[1],
                                                  defn_args, body_block)
          @symbol_table.cfunction = :_main
        end
        call = s(:call, defn[1], call_arguments)
      else
        raise "Unknown function: #{sexp[1]}"
      end
      filtered_stmts(
        args_evaluation,
        s(:decl, 'Fixnum*', var),
        s(:asgn, s(:var, var), call)
      ).with_value_symbol s(:var, var)
    end

    # Returns a sexp which acts as if the Kernel#puts method was called.
    def faked_puts(sexp)
      value = sexp[3][1]
      case value[0]
      when :lit
        return s(:call, :Fixnum_new,
                 s(:args, s(:call, :printf,
                            s(:args, s(:str, '%i\n'), s(:lit, value[1])))))
      when :lvar
        raise 'Unknown local variable' if not @symbol_table.has_lvar? value[1]
        type = @symbol_table.get_lvar_types(value[1]).first
        if type == Fixnum
          return s(:call, :Fixnum_new,
                   s(:args, s(:call, :printf,
                              s(:args, s(:str, '%i\n'),
                                s(:binary_oper, :'->',
                                  s(:var, value[1]), s(:var, :val))))))
        end
      end
      raise 'Only Fixnums can be printed'
    end

    # Functions' definitions don't get translated immediately. We'll wait for the
    # actual call. Meanwhile the defining sexp is saved and we return an empty
    # statements sexp.
    def translate_defn(sexp)
      @functions_definitions[sexp[1]] = sexp
      s(:stmts)
    end
  end
end
