require 'translator/stdlib_classes'

class Translator
  # A module consisting of functions which handle translation of nodes related
  # to classes.
  module Classes
    include StdLibClasses

    # Translates class definition.
    def translate_class(sexp)
      class_name=sexp[1]
      if declared_as_defined_in_stdlib? sexp
        load_stdlib_class sexp
      else
        @symbol_table.in_class class_name do
          set_parent sexp if sexp[2]
          body = translate_generic_sexp(sexp[3])
          implement_generic_methods
        end
        @user_classes << class_name
      end
      # TODO: Build main function for class
      s()
    end

    # Translates self reference into empty sexp with value
    def translate_self(sexp)
      s().with_value s(:var, :self), @symbol_table.cclass
    end

    private

    # Sets the parent-child class relationship in the symbol table.
    def set_parent(sexp)
      raise 'Only constant inheritance is allowed' if sexp[2][0] != :const
      @symbol_table.set_parent sexp[1], sexp[2][1]
    end

    # Generates a structure for class, instance fields and class constructor after
    # all the methods were translated.
    def generate_class_structure(class_name)
      parent_class = @symbol_table.parent class_name
      ivars_table = @symbol_table[class_name][:ivars]
      cvars_table = @symbol_table[class_name][:cvars]
      ifields_declarations =
        ivars_table.keys.map { |key| s(:decl, :'Object*', key.rest) }
      cfields_declarations =
        cvars_table.keys.map { |key| s(:decl, :'Object*', key.rest(2)) }
      structure_definition =
        s(:typedef, s(:struct, nil,
                      s(:block, s(:decl, parent_class, :parent),
                        *ifields_declarations)), class_name)
      @structures_definitions[class_name] = structure_definition
      scname = ('s'+ class_name.to_s).to_sym
      scvar = ('v' + scname.to_s).to_sym
      cstructure_definition =
          s(:typedef, s(:struct, nil,
                        s(:block, s(:decl, :Object, :meta),
                          *cfields_declarations)), scname)
      @structures_definitions[scname] = cstructure_definition
      @globals[scvar] = s(:asgn, s(:decl, scname, scvar),
                          s(:init_block, s(:init_block, s(:lit,
                                           @symbol_table[class_name][:id]))))
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
  
    # Implements all methods for generic (unknown) arguments unless they
    # are already implemented.
    def implement_generic_methods
      cname = @symbol_table.cclass
      chash = @symbol_table[cname]
      if chash.has_key?(:functions_def)
        methods_init = chash[:functions_def].each.map do |fname, fdef|
          if fdef[0] != :stdlib_defn # Ignore stdlib functions
            types = fdef[2].rest.map { nil }
            impl_name = Translator.mangle(fname, cname, types)
            unless function_implemented? impl_name
              @symbol_table.in_class cname do
                implement_function impl_name, fdef, types
              end
            end
          end
        end
      end
    end
  end
end
