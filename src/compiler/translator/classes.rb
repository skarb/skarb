class Translator
  # A module consisting of functions which handle translation of nodes related
  # to classes.
  module Classes
    # Translates class definition.
    def translate_class(sexp)
      class_name=sexp[1]
      @symbol_table.in_class class_name do
        set_parent sexp if sexp[2]
        body = translate_generic_sexp(sexp[3])
      end
      @user_classes << class_name
      # TODO: Build main function for class
      s()
    end

    private

    # Sets the parent-child class relationship in the symbol table.
    def set_parent(sexp)
      raise 'Only constant inheritance is allowed' if sexp[2][0] != :const
      @symbol_table.set_parent sexp[1], sexp[2][1]
    end

    # Generates a structure for class fields and class constructor after all
    # the methods were translates.
    def generate_class_structure(class_name)
      ivars_table = @symbol_table[class_name][:ivars]
      parent_class = @symbol_table.parent class_name
      ivars_table.merge! @symbol_table[parent_class][:ivars] unless parent_class.nil?
      fields_declarations =
        ivars_table.keys.map { |key| s(:decl, :'Object*', key.rest) }
      structure_definition =
        s(:typedef, s(:struct, nil,
                      s(:block, s(:decl, :Object, :meta),
                        *fields_declarations)), class_name)
      @structures_definitions[class_name] = structure_definition
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
      s(:defn, :'Object*', constructor_name, s(:args, *init_args), block)
    end
  end
end
