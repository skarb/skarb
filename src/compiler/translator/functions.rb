class Translator
  # A module consisting of functions which handle translation of nodes related
  # to defining and calling functions and methods.
  module Functions
    # Translates a call to the Kernel#puts method or a simple function defined
    # previously. All other calls cause an error. TODO: split it into multiple
    # methods.
    def translate_call(sexp)
      # Only simple functions without arguments are supported.
      #raise UnsupportedNodeError unless sexp[1].nil? or sexp[3].count > 1
      var = next_var_name
      args_evaluation = s(:stmts)
      call_arguments = s(:args)
      sexp[3].drop(1).each do |x|
        args_evaluation << translate_generic_sexp(x)
        call_arguments << args_evaluation.last.value_symbol
      end

      fclass = get_class_name(sexp[1])
      old_class = @symbol_table.cclass
      @symbol_table.cclass = fclass
      fname = get_function_name(sexp[2], fclass)
      if sexp[2] == :puts
        call = faked_puts sexp
      elsif defn = @functions_definitions[fname]
        # If the function has been already defined translate it's body and save
        # the output in @functions_implementations.
        unless @functions_implementations.has_key? fname
          old_function = @symbol_table.cfunction
          @symbol_table.cfunction = fname
          defn_args = s(:args)
          call_args_eval_stmts = []
          if sexp[3].count < defn[2].count or sexp[3].count > defn[2].count + 1
            raise "Wrong number of parameters"
          end
          defn[2].drop(1).each do |arg|
            @symbol_table.add_lvar arg
            # FIXME: set the actual type
            @symbol_table.set_lvar_types arg, [Object]
            defn_args << s(:decl, :'Object*', arg)
          end
          if sexp[1] != :no_class and sexp[1][0] != :const
            call_arguments << s(:lit, :NULL) if sexp[3].count == defn[2].count
            @symbol_table.add_lvar :self 
            if sexp[1]!=nil and sexp[1] != :no_class and sexp[1][0] == :const
              defn_args << s(:decl, (fclass.to_s+"_const*").to_sym, :self)
              @symbol_table.set_lvar_types :self, [(fclass.to_s+"_const*").to_sym]
            else
              defn_args << s(:decl, fclass.star, :self)
              @symbol_table.set_lvar_types :self, [fclass]
            end
          end
          
          args_evaluation = filtered_stmts(*args_evaluation.rest)
          body = translate_generic_sexp(defn[3][1])
          body_block = filtered_block(body, s(:return, body.value_symbol))
          # FIXME: set the actual return type
          @functions_implementations[fname] = s(:defn, :'Object*', fname,
                                                  defn_args, body_block)
          @symbol_table.cfunction = old_function
        end
        call = s(:call, fname, call_arguments)
      else
        call = s(:call, fname, call_arguments)
        #raise "Unknown function: #{sexp[2]}"
      end
      @symbol_table.cclass = old_class
      filtered_stmts(
        args_evaluation,
        s(:decl, :'Object*', var),
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
        elsif type == Float
          return s(:call, :Fixnum_new,
                   s(:args, s(:call, :printf,
                              s(:args, s(:str, '%g\n'),
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
      @functions_definitions[get_function_name(sexp[1])] = sexp
      s(:stmts)
    end

    def get_class_name(class_expr)
      if class_expr.nil? || class_expr==:no_class
        @symbol_table.cclass
      else
        # TODO: If the type is not known return something
        types = translate_generic_sexp(class_expr).value_types
        types.first
      end
    end

    def get_function_name(function_name, class_name = nil)
      function_name if class_name == :no_class
      class_name = @symbol_table.cclass if class_name.nil?
      (class_name.to_s + '_' + function_name.to_s).to_sym
    end
  end
end
