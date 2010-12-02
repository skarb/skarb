class Translator
  # A module consisting of functions which handle translation of nodes related
  # to defining and calling functions and methods.
  #
  # Function names are mangled in order to allow overloading. Functions which
  # don't accept arguments are prefixed with a '_'. If a function A accepts
  # arguments whose types are respectively X, Y and Z its mangled name will be
  # '_X_Y_Z_A'.  See Functions#mangle for an implementation.
  module Functions
    # Translates a call to the Kernel#puts method or a simple function defined
    # previously. All other calls cause an error.
    def translate_call(sexp)
      # Only simple functions without arguments are supported.
      raise UnsupportedNodeError unless sexp[1].nil? or sexp[3].count > 1
      if sexp[2] == :puts
        call_faked_puts sexp
      elsif function_is_defined? sexp[2]
        call_defined_function sexp
      else
        raise "Unknown function: #{sexp[1]}"
      end
    end

    # Returns a sexp which acts as if the Kernel#puts method was called.
    def call_faked_puts(sexp)
      value = sexp[3][1]
      case value[0]
      when :lit
        retval = s(:call, :printf,
                   s(:args, s(:str, '%i\n'), s(:lit, value[1])))
      when :lvar
        raise 'Unknown local variable' if not @symbol_table.has_lvar? value[1]
        type = @symbol_table.get_lvar_types(value[1]).first
        if type == Fixnum
          retval = s(:call, :printf,
                     s(:args, s(:str, '%i\n'),
                       s(:binary_oper, :'->',
                         s(:var, value[1]), s(:var, :val))))
        elsif type == Float
          retval = s(:call, :printf,
                     s(:args, s(:str, '%g\n'),
                       s(:binary_oper, :'->',
                         s(:var, value[1]), s(:var, :val))))
        end
      end
      raise 'Only Fixnums can be printed' if not retval
      retval.with_value_symbol s(:lit, 0)
    end

    # Functions' definitions don't get translated immediately. We'll wait for the
    # actual call. Meanwhile the defining sexp is saved and we return an empty
    # statements sexp.
    def translate_defn(sexp)
      @functions_definitions[sexp[1]] = sexp
      s(:stmts)
    end

    private

    # Returns true if a given function (not a method!) has been already defined.
    def function_is_defined?(name)
      @functions_definitions.include? name
    end

    # Returns a sexp calling a defined function. If the function hasn't been
    # implemented yet implement_function is called.
    def call_defined_function(sexp)
      var = next_var_name
      # Evaluate arguments. We need to know what their type is in order to call
      # appropriate overloaded function.
      args_evaluation = sexp[3].rest.map { |arg_sexp| translate_generic_sexp arg_sexp }
      # Get the defn sexp in which the function has been defined.
      defn = @functions_definitions[sexp[2]]
      # Get types of arguments. FIXME: first won't work!
      types = args_evaluation.map { |arg| arg.value_types.first }
      # Have we got an implementation of this function for given args' types?
      implement_function defn, types unless function_has_implementation? defn, types
      call = s(:call, mangle(defn[1], types),
               s(:args, *args_evaluation.map { |arg| arg.value_symbol } ))
      filtered_stmts(
        filtered_stmts(*args_evaluation),
        s(:decl, 'Fixnum*', var),
        s(:asgn, s(:var, var), call)
      ).with_value_symbol s(:var, var)
    end

    # Returns a mangled function name for a given name and a array of arguments'
    # types.
    def mangle(name, args_types)
      [*([nil] + args_types), name].join('_').to_sym
    end

    # Returns true if an implementation of the given function (not a method!)
    # defined with a given defn sexp and implemented for given arguments' types
    # has been already added to @functions_implementations.
    def function_has_implementation?(defn, args_types)
      @functions_implementations.has_key? mangle(defn[1], args_types)
    end

    # Translates a given function and adds its implementation to
    # @functions_implementations.
    def implement_function(defn, args_types)
      name = mangle(defn[1], args_types)
      @symbol_table.cfunction = name
      defn_args = s(:args)
      defn[2].drop(1).each do |arg|
        @symbol_table.add_lvar arg
        # FIXME: set the actual type
        @symbol_table.set_lvar_types arg, [Fixnum]
        defn_args << s(:decl, 'Fixnum*', arg)
      end
      body = translate_generic_sexp(defn[3][1])
      body_block = filtered_block(body, s(:return, body.value_symbol))
      # FIXME: set the actual return type
      @functions_implementations[name] = s(:defn, 'Fixnum*', name,
                                              defn_args, body_block)
      @symbol_table.cfunction = :_main
    end
  end
end
