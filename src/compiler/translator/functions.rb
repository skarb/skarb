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
    # Translates a method call. Kernel#puts calls and constructors are treated
    # in special way.
    def translate_call(sexp)
      if sexp[2] == :puts
        call_faked_puts sexp
      elsif sexp[2] == :new
        call_constructor sexp[2], sexp
      else
        look_up_and_call sexp
      end
    end

    # Returns an array containing local variables declarations (but not
    # parameters since they are already defined)
    def lvars_declarations
      selector = lambda { |k,v| v[:kind] == :local }
      mapper = lambda { |k| s(:decl, :'Object*', k.first) }
      @symbol_table.lvars_table.select(&selector).map(&mapper)
    end

    # Calls Object_Object_puts.
    def call_faked_puts(sexp)
      value = sexp[3][1]
      arg_evaluation = translate_generic_sexp value
      filtered_stmts(
        arg_evaluation,
        s(:call, :Object_Object_puts, s(:args, arg_evaluation.value_sexp))
      ).with_value s(:var, :nil), NilClass
    end

    # Functions' definitions don't get translated immediately. We'll wait for the
    # actual call. Meanwhile the defining sexp is saved and we return an empty
    # statements sexp.
    def translate_defn(sexp)
      class_name = @symbol_table.cclass
      @symbol_table.add_function sexp[1], sexp
      s(:stmts)
    end

    private

    # Returns true if a given function (method) has been already defined.
    def function_defined?(name, type = @symbol_table.cclass)
      @symbol_table[type][:functions_def].has_key? name
    end

    # Tries to find a method in the inheritance chain and call it.
    def look_up_and_call(sexp)
      type = get_class_name(sexp[1]).to_s.to_sym
      while type
        if function_defined? sexp[2], type
          return call_defined_function sexp[2], type, sexp
        end
        type = @symbol_table.parent type
      end
      raise "Unknown function or method: #{sexp[2]}"
    end

    # Evaluates arguments of a call sexp. We need to know what their type is in
    # order to call an appropriate overloaded function.
    def evaluate_call_args(sexp, class_name)
      if sexp[1].nil?
        args = [s().with_value(s(:var, :self), class_name)]
      else
        args = [translate_generic_sexp(sexp[1])]
      end
      args + sexp[3].rest.map { |arg_sexp| translate_generic_sexp arg_sexp }
    end

    # Finds a C function implementing method with a given name in a given class
    # which accepts given evaluated arguments. If the function isn't implemeted
    # yet its AST gets translated.
    def find_defined_function(class_name, def_name, args_evaluation)
      defn = @symbol_table[class_name][:functions_def][def_name]
      types = args_evaluation.map { |arg| arg.value_type }
      impl_name = mangle(def_name, class_name, types.rest)
      # Have we got an implementation of this function for given args' types?
      unless function_implemented? impl_name
        @symbol_table.in_class class_name do
          implement_function impl_name, defn, types
        end
      end
      impl_name
    end

    # Returns a sexp calling a defined function. If the function hasn't been
    # implemented yet implement_function is called.
    def call_defined_function(def_name, class_name, sexp)
      args = evaluate_call_args sexp, class_name
      # Get the defn sexp in which the function has been defined.
      if @symbol_table.class_defined_in_stdlib? class_name
        impl_name = @symbol_table[class_name][:functions_def][def_name]
        ret_type = :Object
      else
        impl_name = find_defined_function class_name, def_name, args
        ret_type = return_type impl_name
      end
      var = next_var_name
      filtered_stmts(
        filtered_stmts(*args),
        s(:decl, :'Object*', var),
        s(:asgn, s(:var, var), s(:call, impl_name,
                                 s(:args, *args.map { |arg| arg.value_sexp } )))
      ).with_value s(:var, var), ret_type
    end

    # Returns a sexp calling a constructor. If the constructor hasn't been
    # implemented yet implement_constructor is called.
    def call_constructor(def_name, sexp)
      var = next_var_name
      class_name = get_class_name(sexp[1])
      if function_defined? :initialize, class_name 
        # Evaluate arguments. We need to know what their type is in order to call
        # appropriate overloaded function.
        args_evaluation = sexp[3].rest.map { |arg_sexp| translate_generic_sexp arg_sexp }
        # Get the defn sexp in which the function has been defined.
        defn = @symbol_table[class_name][:functions_def][:initialize]
        # Get types of arguments.
        types = args_evaluation.map { |arg| arg.value_type }
        impl_init_name = mangle(:initialize, class_name, types)
        impl_name = mangle(def_name, class_name, types)
        init_fun = unpack_static(@symbol_table.in_class(class_name) do
          implement_function impl_init_name, defn, types
        end)
        init_args = init_fun[3].rest(2)
        init_body = init_fun[4].rest.rest(-1)
        @functions_implementations[impl_name] =
          class_constructor(class_name, impl_name, impl_init_name, init_args)
      else
        args_evaluation=[]
        impl_name = mangle(def_name, class_name, [])
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

    # Returns the class name of a given expression. If it's nil it returns the
    # class we're currently in. It's used to determine whose method are we
    # supposed to call when translating a call sexp.
    def get_class_name(class_expr)
      return @symbol_table.cclass if class_expr.nil?
      translate_generic_sexp(class_expr).value_type
    end

    # Returns a mangled function name for a given name, class, and
    # an array of arguments' types.
    def mangle(name, class_name, args_types)
      [class_name.to_s, name.to_s, *args_types].join('_').to_sym
    end

    # Returns true if an implementation of the given function (or method)
    # defined with a full name has been already added to @functions_implementations.
    def function_implemented?(name)
      @functions_implementations.has_key? name
    end

    # Translates a given function definition
    def process_function_definition(impl_name, defn, args_types)
      # We don't want to destroy the original table
      defn_args = s(:args)
      lvars = []
      body = @symbol_table.in_function defn[1] do
        ([:self] + defn[2].drop(1)).zip args_types do |arg, type|
          @symbol_table.add_lvar arg
          @symbol_table.set_lvar_type arg, type
          @symbol_table.set_lvar_kind arg, :param
          defn_args << s(:decl, :'Object*', arg)
        end
        lvars = lvars_declarations
        translate_generic_sexp(defn[3][1])
      end
      body_block = filtered_block(*lvars, body, s(:return, body.value_sexp))
      s(:static, s(:defn, :'Object*', impl_name, defn_args, body_block)
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

    # Generates prototypes of all functions' implementations.
    def generate_prototypes
      @functions_implementations.values.map do |fun|
        if fun[0] == :static
          s(:static, s(:prototype, *fun[1][1,3]))
        else
          s(:prototype, *fun[1,3])
        end
      end
    end

    # If a given sexp is a static sexp its second element is returned. Otherwise
    # the original sexp is returned.
    def unpack_static(sexp)
      if sexp[0] == :static
        sexp[1]
      else
        sexp
      end
    end
  end
end
