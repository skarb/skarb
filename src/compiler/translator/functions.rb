require 'helpers'
require 'translator/functions/mangling'

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
    include Helpers
    include Mangling

    # Translates a method call. Constructors are treated in special way.
    def translate_call(sexp)
      if sexp[2] == :new
        if sexp[1].nil? 
          msexp = sexp.clone
          msexp[1] = s(:const, @symbol_table.cclass)
          call_constructor msexp
        else
          call_constructor sexp
        end
      else
        # Class is not explicit
        if sexp[1].nil?
          msexp = sexp.clone
          msexp[1] = s(:const, @symbol_table.cclass)
          ret_val = look_up_and_call msexp
        end
        ret_val = look_up_and_call sexp if ret_val.nil?
        die "Unknown function or method: #{sexp[2]}" if ret_val.nil?
        ret_val
      end
    end

    # Returns an array containing local variables declarations (but not
    # parameters since they are already defined)
    def lvars_declarations
      selector = lambda { |k,v| v[:kind] == :local }
      mapper = lambda { |k| s(:decl, :'Object*', escape_name(k.first)) }
      @symbol_table.lvars_table.select(&selector).map(&mapper)
    end

    # Functions' definitions don't get translated immediately. We'll wait for the
    # actual call. Meanwhile the defining sexp is saved and we return an empty
    # statements sexp.
    def translate_defn(sexp)
      @symbol_table.add_function sexp[1], sexp
      implement_generic_function sexp[1], @symbol_table.cclass
    end

    # Static functions' definitions don't get translated immediately. We'll wait
    # for the actual call. Meanwhile the defining sexp is saved and we return
    # an empty statements sexp.
    def translate_defs(sexp)
      class_name = translate_generic_sexp(sexp[1]).class_type
      sexp = sexp.clone
      sexp.delete_at 1
      sexp[1] = ('s_'+sexp[1].to_s).to_sym
      @symbol_table.in_class class_name do
        @symbol_table.add_function sexp[1], sexp
      end
      implement_generic_function sexp[1], class_name
    end

    # Translates a call to the []= method. It's treated exactly as a call sexp.
    def translate_attrasgn(sexp)
      sexp = sexp.clone
      sexp[0] = :call
      translate_call sexp
    end

    private

    # Returns true if a given function (method) has been already defined.
    def function_defined?(name, type = @symbol_table.cclass)
      @symbol_table[type][:functions_def].has_key? name
    end

    # Tries to find a method in the inheritance chain and call it.
    def look_up_and_call(sexp)
      class_expr = evaluate_class_expr(sexp[1])
      type = class_expr.value_type.to_s.to_sym
      # Do not translate recursive calls until their type is determined 
      return s().with_value_type :recur if type == :recur
      # If the type is unknown we have to perform method search at runtime
      return generate_runtime_call class_expr, sexp if type.empty?
      if type == :Class
        sexp = sexp.clone
        sexp[2] = ('s_'+sexp[2].to_s).to_sym
        type = class_expr.class_type
      end
      while type
        if function_defined? sexp[2], type
          return call_defined_function sexp[2], type, sexp
        end
        type = @symbol_table.parent type
      end
    end

    # Generate AST representing args evaluation and call_method call.
    def generate_runtime_call(class_expr, sexp)
      args = evaluate_call_args sexp
      var = next_var_name
      args_tab = next_var_name
      filtered_stmts(
        filtered_stmts(class_expr),
        filtered_stmts(*args),
        s(:asgn,
          s(:decl, :'Object*', "#{args_tab}[#{args.length}]".to_sym),
          s(:init_block, *args.map { |arg| arg.value_sexp })),
        s(:decl, :'Object*', var),
        s(:asgn,
          s(:var, var),
          s(:call, :call_method,
            s(:args,
              s(:binary_oper, :'->',
                s(:cast, :'Object*', class_expr.value_sexp),
                s(:var, :type)),
              s(:var, :classes_dictionary),
              # Small hack: length of the string is converted to char
              # and concatenated at the beggining.
              s(:str, sexp[2].length.chr+sexp[2].to_s),
              s(:var, args_tab))))).with_value_sexp s(:var, var)
    end

    # Evaluates arguments of a call sexp. We need to know what their type is in
    # order to call an appropriate overloaded function.
    def evaluate_call_args(sexp, class_name=nil)
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
    def find_defined_function(class_name, def_name, args_types)
      defn = @symbol_table[class_name][:functions_def][def_name].last
      version = @symbol_table[class_name][:functions_def][def_name].length - 1
      # Here we append version number to function name
      impl_name = Translator.mangle(def_name, version, class_name, args_types)
      args_types.unshift class_name
      # Have we got an implementation of this function for given args' types?
      unless function_implemented? impl_name
        @symbol_table.in_class class_name do
          @functions_implementations[impl_name] = s().with_value_type :recur
          ret_type = process_function_definition(impl_name, defn, args_types).value_type
          @functions_implementations[impl_name] = s().with_value_type ret_type
          implement_function impl_name, defn, args_types
        end
      end
      impl_name
    end

    # Returns a sexp calling a defined function. If the function hasn't been
    # implemented yet implement_function is called.
    def call_defined_function(def_name, class_name, sexp)
      args = evaluate_call_args sexp, class_name
      args_types = args.rest.map { |arg| arg.value_type }
      # Do not translate recursive calls until their type is determined 
      return s().with_value_type :recur if args_types.include? :recur
      # Get the defn sexp in which the function has been defined.
      if @symbol_table.class_defined_in_stdlib? class_name
        defn = @symbol_table[class_name][:functions_def][def_name].last
        impl_name = defn[1]
        if defn.value_type.is_a? Hash
          ret_type = defn.value_type[args_types.join '_']
        else
          ret_type = defn.value_type
        end
      else
        impl_name = find_defined_function class_name, def_name, args_types
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
    def call_constructor(sexp)
      var = next_var_name
      def_name = sexp[2]
      class_expr = evaluate_class_expr(sexp[1])
      class_name = class_expr.class_type
      die "Unknown class: '#{class_name}'" unless @symbol_table[class_name]
      args_evaluation=[]
      impl_name = Translator.mangle(def_name, 0, class_name, [])
      if not @symbol_table.class_defined_in_stdlib? class_name
        if function_defined? :initialize, class_name
          # Evaluate arguments. We need to know what their type is in order to call
          # appropriate overloaded function.
          args_evaluation = sexp[3].rest.map { |arg_sexp| translate_generic_sexp arg_sexp }
          # Get the defn sexp in which the function has been defined.
          defn = @symbol_table[class_name][:functions_def][:initialize].last
          version = @symbol_table[class_name][:functions_def][:initialize].length - 1
          # Get types of arguments.
          types = args_evaluation.map { |arg| arg.value_type }
          impl_init_name = Translator.mangle(:initialize, version, class_name, types)
          impl_name = Translator.mangle(def_name, 0, class_name, types)
          init_fun = unpack_static(@symbol_table.in_class(class_name) do
            implement_function impl_init_name, defn, types
          end)
          init_args = init_fun[3].rest(2)
          init_body = init_fun[4].rest.rest(-1)
          @functions_implementations[impl_name] =
            class_constructor(class_name, impl_name, impl_init_name, init_args)
        else
          @functions_implementations[impl_name] =
            class_constructor(class_name, impl_name)
        end
      end
      call = s(:call, impl_name,
               s(:args, *args_evaluation.map { |arg| arg.value_sexp } ))
      filtered_stmts(
        filtered_stmts(class_expr),
        filtered_stmts(*args_evaluation),
        s(:decl, :'Object*', var),
        s(:asgn, s(:var, var), call)
      ).with_value s(:var, var), class_name
    end

    # Returns the translated class expression. If it's nil it returns the
    # class we're currently in. It's used to determine whose method are we
    # supposed to call when translating a call sexp.
    def evaluate_class_expr(class_expr)
      return s().with_value_type @symbol_table.cclass if class_expr.nil?
      translate_generic_sexp(class_expr)
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
        body = translate_generic_sexp(defn[3][1])
        lvars = lvars_declarations
        body
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

    # Implements function with generic arguments. It always implements
    # last version found on the stack and puts it in class function
    # dictionary.
    def implement_generic_function(fname, cname)
      if function_defined? fname, cname 
        fdef = @symbol_table[cname][:functions_def][fname].last
        version = @symbol_table[cname][:functions_def][fname].length - 1
        types = fdef[2].rest.map { nil }
        impl_name = Translator.mangle(fname, version, cname, types)
        unless function_implemented? impl_name
          @symbol_table.in_class cname do
            implement_function impl_name, fdef, types
          end
          assign_function_to_class_dict(fname, impl_name, cname, types.length+1)
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
   
    # Returns sexp containing assignment of function and wrapper pointers to
    # proper fields in class functions dictionary. 
    def assign_function_to_class_dict(fname, impl_name, class_name, args_count)
      var = next_var_name
      s(:stmts,
        s(:asgn,
          s(:decl, :int, var),
          s(:call, (class_name.to_s + "_hash").to_sym,
            s(:args, s(:str, fname.to_s), s(:lit, fname.length)))),
        s(:asgn,
          s(:binary_oper, :'.',
            s(:indexer,
              s(:var, (class_name.to_s + "_words").to_sym), s(:var, var)),
            s(:var, :function)),
          s(:l_unary_oper, :'&', s(:var, impl_name))),
        s(:asgn,
          s(:binary_oper, :'.',
            s(:indexer,
              s(:var, (class_name.to_s + "_words").to_sym), s(:var, var)),
            s(:var, :wrapper)),
          s(:l_unary_oper, :'&', s(:var, :"wrapper_#{args_count}")))).
          with_value_sexp(s(:var, :nil))
    end
  end
end
