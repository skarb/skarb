require 'translator/stdlib_classes'

class Translator
  # A module consisting of functions which handle translation of nodes related
  # to classes.
  module Classes
    include StdLibClasses

    # Translates class definition.
    def translate_class(sexp)
      class_name=sexp[1]
      @symbol_table.add_class sexp[1]
      if declared_as_defined_in_stdlib? sexp
        load_stdlib_class sexp
        s()
      else
        body = s() 
        @symbol_table.in_class class_name do
          set_parent sexp if sexp[2]
          body = translate_generic_sexp(sexp[3])
        end
        @user_classes << class_name
        build_main_function(class_name, body)
      end
    end

    # Translates self reference into empty sexp with value
    def translate_self(sexp)
      cclass = @symbol_table.cclass
      return @symbol_table[cclass][:value] if @symbol_table.cfunction == :_main
      s().with_value s(:var, :self), cclass
    end

    private

    # Sets the parent-child class relationship in the symbol table.
    def set_parent(sexp)
      raise 'Only constant inheritance is allowed' if sexp[2][0] != :const
      @symbol_table.set_parent sexp[1], sexp[2][1]
    end

    # Generates a structure for instance fields after
    # all the methods were translated.
    def generate_class_structure(class_name)
      parent_class = @symbol_table.parent class_name
      ivars_table = @symbol_table[class_name][:ivars]
      ifields_declarations =
        ivars_table.keys.map { |key| s(:decl, :'Object*', key.rest) }
      structure_definition =
        s(:typedef, s(:struct, nil,
                      s(:block, s(:decl, parent_class, :parent),
                        *ifields_declarations)), class_name)
      @structures_definitions[class_name] = structure_definition
    end

    # Generates a structure for class fields
    def generate_class_static_structure(class_name)
      parent_class = @symbol_table.parent class_name
      cvars_table = @symbol_table[class_name][:cvars]
      cfields_declarations =
        cvars_table.keys.map { |key| s(:decl, :'Object*', key.rest(2)) }
      scname = ('s'+ class_name.to_s).to_sym
      scvar = ('v' + scname.to_s).to_sym
      cstructure_definition =
        s(:typedef, s(:struct, nil,
                      s(:block, s(:decl, :Class, :meta),
                        *cfields_declarations)), scname)
      @structures_definitions[scname] = cstructure_definition
      @globals[scvar] = s(:asgn, s(:decl, scname, scvar),
                          s(:init_block,
                            s(:init_block,
                              s(:init_block,
                                s(:lit, @symbol_table[:Class][:id])),
                              s(:init_block,
                                s(:lit, @symbol_table[class_name][:id])))))
    end

    # Returns C constructor code for given class
    def class_constructor(class_name, constructor_name, init_name=nil, init_args=[])
      block = s(:block,
          s(:asgn,
            s(:decl, :'Object*', :self),
            s(:call, :xmalloc,
              s(:args, s(:call, :sizeof, s(:args, s(:lit, class_name)))))),
          s(:asgn,
            s(:binary_oper, :'->', s(:var, :self), s(:var, :type)),
            s(:lit, @symbol_table[class_name][:id])))
      unless init_name.nil?
        block << s(:call, init_name,
                   s(:args, s(:var, :self),
                      *(init_args.map { |x| s(:var, x[2]) })))
      end
      block << s(:return, s(:var, :self))
      s(:static,
        s(:defn, :'Object*', constructor_name, s(:args, *init_args), block))
    end
  
    # Puts main function for class in @functions_implementations and returns
    # sexp calling it.
    def build_main_function(class_name, body)
      return s() if body.nil? or body.length < 2
      fname = ([class_name, "main"].join '_').to_sym
      body_block =
        filtered_block(
          *lvars_declarations,
          s(:decl, class_name, :self_s),
          s(:asgn,
            s(:decl, :'Object*', :self),
            s(:cast, :'Object*', s(:var, :'&self_s'))), body,
          s(:return, body.value_sexp))
      @functions_implementations[fname] =
        s(:static, s(:defn, :'Object*', fname, s(:args), body_block)).
        with_value_type body.value_type
      s(:call, fname, s(:args))
    end
  end
end
