class Translator
  # A module consisting of functions which handle translation of nodes related
  # to defining and calling functions and methods.
  #
  # Function names are mangled in order to allow overloading. Function name is
  # always prefixed with class name (names are separated by '_'). Then comes
  # the arguments types: If a function A, method of class B, accepts arguments
  # whose types are respectively X, Y and Z its mangled name will be 'B_A_X_Y_Z'.
  # See Functions#mangle for an implementation.
  module Functions
    # Translates a call to the Kernel#puts method or a simple function defined
    # previously. All other calls cause an error.
    def translate_call(sexp)
      if sexp[2] == :puts
        call_faked_puts sexp
      elsif sexp[2] == :new
        def_name = get_defined_function_name(sexp[2], get_class_name(sexp[1]))
        call_constructor def_name, sexp
      else
        look_up_and_call sexp
      end
    end

    # Calls Object_Object_puts.
    def call_faked_puts(sexp)
      value = sexp[3][1]
      arg_evaluation = translate_generic_sexp value
      filtered_stmts(
        arg_evaluation,
        s(:call, :Object_Object_puts, s(:args, arg_evaluation.value_sexp))
      ).with_value s(:call, :Fixnum_new, s(:args, s(:lit, 0))), Fixnum
    end

    # Functions' definitions don't get translated immediately. We'll wait for the
    # actual call. Meanwhile the defining sexp is saved and we return an empty
    # statements sexp.
    def translate_defn(sexp)
      class_name = @symbol_table.cclass
      def_name = get_defined_function_name(sexp[1], class_name)
      @functions_definitions[def_name] = sexp
      s(:stmts)
    end

    private

    # Returns true if a given function (not a method!) has been already defined.
    def function_is_defined?(name)
      @functions_definitions.include? name
    end

    # Tries to find a method in the inheritance chain and call it.
    def look_up_and_call(sexp)
      type = get_class_name(sexp[1])
      while type
        name = get_defined_function_name(sexp[2], type)
        return call_defined_function name, type, sexp if function_is_defined? name
        type = @symbol_table.parent type
      end
      raise "Unknown function or method: #{sexp[2]}"
    end

    # Returns a sexp calling a defined function. If the function hasn't been
    # implemented yet implement_function is called.
    def call_defined_function(def_name, class_name, sexp)
      var = next_var_name
      # Evaluate arguments. We need to know what their type is in order to call
      # appropriate overloaded function.
      if sexp[1].nil?
        args_evaluation = [s().with_value(s(:var, :self), class_name)]
      else
        args_evaluation = [translate_generic_sexp(sexp[1])]
      end
      args_evaluation += sexp[3].rest.map { |arg_sexp| translate_generic_sexp arg_sexp }
      # Get the defn sexp in which the function has been defined.
      defn = @functions_definitions[def_name]
      types = args_evaluation.map { |arg| arg.value_type }
      impl_name = mangle(def_name, types.rest)
      # Have we got an implementation of this function for given args' types?
      unless function_is_implemented? impl_name
        @symbol_table.in_class class_name do
          implement_function impl_name, defn, types
        end
      end
      call = s(:call, impl_name,
               s(:args, *args_evaluation.map { |arg| arg.value_sexp } ))
      filtered_stmts(
        filtered_stmts(*args_evaluation),
        s(:decl, :'Object*', var),
        s(:asgn, s(:var, var), call)
      ).with_value s(:var, var), return_type(impl_name)
    end

    # Returns a sexp calling a constructor. If the constructor hasn't been
    # implemented yet implement_constructor is called.
    def call_constructor(def_name, sexp)
      var = next_var_name
      class_name = get_class_name(sexp[1])
      init_name = get_defined_function_name(:initialize, class_name)
      if function_is_defined? init_name
        # Evaluate arguments. We need to know what their type is in order to call
        # appropriate overloaded function.
        args_evaluation = sexp[3].rest.map { |arg_sexp| translate_generic_sexp arg_sexp }
        # Get the defn sexp in which the function has been defined.
        defn = @functions_definitions[init_name]
        # Get types of arguments.
        types = args_evaluation.map { |arg| arg.value_type }
        impl_init_name = mangle(init_name, types)
        impl_name = mangle(def_name, types)
        init_fun = @symbol_table.in_class class_name do
          implement_function impl_init_name, defn, types
        end
        init_args = init_fun[3].rest(2)
        init_body = init_fun[4].rest.rest(-1)
        @functions_implementations[impl_name] =
          class_constructor(class_name, impl_name, impl_init_name, init_args)
      else
        args_evaluation=[]
        impl_name = mangle(def_name, [])
        @functions_implementations[impl_name] =
          class_constructor(class_name, impl_name)
      end
      call = s(:call, impl_name,
               s(:args, *args_evaluation.map { |arg| arg.value_sexp } ))
      filtered_stmts(
        filtered_stmts(*args_evaluation),
        s(:decl, :'Object*', var),
        s(:asgn, s(:var, var), call)
      ).with_value s(:var, var), class_name
    end

    def get_class_name(class_expr)
      return @symbol_table.cclass if class_expr.nil?
      translate_generic_sexp(class_expr).value_type
    end

    # Returns function name preceded by class name
    def get_defined_function_name(name, class_name)
      [class_name.to_s, name.to_s].join('_').to_sym
    end

    # Returns a mangled function name for a given name and a array of arguments'
    # types.
    def mangle(name, args_types)
      [name, *args_types].join('_').to_sym
    end

    alias :get_implemented_function_name :mangle

    # Returns true if an implementation of the given function (or method)
    # defined with a full name has been already added to @functions_implementations.
    def function_is_implemented?(name)
      @functions_implementations.has_key? name
    end

    # Translates a given function definition
    def process_function_definition(impl_name, defn, args_types)
      # We don't want to destroy the original table
      defn_args = s(:args)
      body = @symbol_table.in_function defn[1] do
        ([:self] + defn[2].drop(1)).zip args_types do |arg, type|
          @symbol_table.add_lvar arg
          @symbol_table.set_lvar_type arg, type
          defn_args << s(:decl, :'Object*', arg)
        end
        translate_generic_sexp(defn[3][1])
      end
      body_block = filtered_block(body, s(:return, body.value_sexp))
      s(:defn, :'Object*', impl_name, defn_args, body_block
       ).with_value_type body.value_type
    end

    # Adds function implementation to @functions_implementations.
    def implement_function(impl_name, defn, args_types)
      @functions_implementations[impl_name] =
        process_function_definition(impl_name, defn, args_types)
    end

    # Returns the type of values returned by a function with given arguments.
    def return_type(impl_name)
      @functions_implementations[impl_name].value_type
    end
  end
end
