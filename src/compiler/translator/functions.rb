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
      # Only simple functions without arguments are supported.
      raise UnsupportedNodeError unless sexp[1].nil? or sexp[3].count > 1
      class_name = get_class_name(sexp[1])
      def_name = get_defined_function_name(sexp[2], class_name)
      if sexp[2] == :puts
        call_faked_puts sexp
      elsif sexp[2] == :new
        call_constructor def_name, sexp
      elsif function_is_defined? def_name
        call_defined_function def_name, sexp
      else
        raise "Unknown function: #{sexp[1]}"
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

    # Returns a sexp calling a defined function. If the function hasn't been
    # implemented yet implement_function is called.
    def call_defined_function(def_name, sexp)
      var = next_var_name
      class_name = get_class_name(sexp[1])
      # Evaluate arguments. We need to know what their type is in order to call
      # appropriate overloaded function.
      args_evaluation = sexp[3].rest.map { |arg_sexp| translate_generic_sexp arg_sexp }
      # Get the defn sexp in which the function has been defined.
      defn = @functions_definitions[def_name]
      types = args_evaluation.map { |arg| arg.value_type }
      impl_name = mangle(def_name, types)
      # Have we got an implementation of this function for given args' types?
      unless function_is_implemented? impl_name
        old_class = @symbol_table.cclass
        @symbol_table.cclass = class_name
        implement_function impl_name, defn, types
        @symbol_table.cclass = old_class
      end
      call = s(:call, impl_name,
               s(:args, *args_evaluation.map { |arg| arg.value_sexp } ))
      filtered_stmts(
        filtered_stmts(*args_evaluation),
        s(:decl, :'Object*', var),
        s(:asgn, s(:var, var), call)
      ).with_value_sexp s(:var, var)
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
        old_class = @symbol_table.cclass
        @symbol_table.cclass = class_name
        init_fun =  process_function_definition impl_init_name, defn, types
        @symbol_table.cclass = old_class
        init_args = init_fun[3].rest
        init_body = init_fun[4].rest.rest(-1)
        @functions_implementations[impl_name] =
          class_constructor(class_name, impl_name, init_args, init_body)
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
      ).with_value_sexp s(:var, var)
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
      args_types = args_types.clone
      prev_function, @symbol_table.cfunction = @symbol_table.cfunction, defn[1]
      defn_args = s(:args)
      defn[2].drop(1).each do |arg|
        type = args_types.shift
        @symbol_table.add_lvar arg
        @symbol_table.set_lvar_type arg, type
        defn_args << s(:decl, :'Object*', arg)
      end
      body = translate_generic_sexp(defn[3][1])
      body_block = filtered_block(body, s(:return, body.value_sexp))
      @symbol_table.cfunction = prev_function
      # FIXME: set the actual return type
      s(:defn, :'Object*', impl_name, defn_args, body_block)
    end

    # Adds function implementation to @functions_implementations.
    def implement_function(impl_name, defn, args_types)
      @functions_implementations[impl_name] =
        process_function_definition(impl_name, defn, args_types)
    end
  end
end
