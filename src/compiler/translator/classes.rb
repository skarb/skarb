class Translator
  # A module consisting of functions which handle translation of nodes related
  # to classes.
  module Classes
    # Generates a structure for class fields and class constructor after all
    # the methods were translates.
    def generate_class_structure(class_name)
      # Build structure
      ivars_table = @symbol_table[class_name][:ivars]
      fields_declarations =
        ivars_table.keys.map { |key| s(:decl, :'Object*', key.rest) }
      structure_definition =
        s(:typedef, s(:struct, nil,
                      s(:block, s(:decl, :Object, :meta),
                        *fields_declarations)), class_name)
      @structures_definitions[class_name] = structure_definition
    end

    def class_constructor(class_name, constructor_name, init_args=[], init_body=[])
      s(:defn, :'Object*', constructor_name, s(:args, *init_args),
        s(:block,
          s(:asgn,
            s(:decl, :'Object*', :self),
            s(:call, :xmalloc,
              s(:args, s(:call, :sizeof, s(:args, s(:lit, class_name)))))),
          s(:asgn,
            s(:binary_oper, :'->', s(:var, :self), s(:var, :type)),
            s(:lit, @symbol_table[class_name][:id])),
          *init_body,
          s(:return, s(:var, :self))))
    end

    # Translates class definition.
    def translate_class(sexp)
      class_name=sexp[1]
      higher_class=@symbol_table.cclass
      @symbol_table.cclass=class_name
      set_parent sexp if sexp[2]
      body = translate_generic_sexp(sexp[3])

      @symbol_table.cclass=higher_class
      @user_classes << class_name
      # TODO: Build main function for class
      s()
    end

    def translate_scope(sexp)
       sexps = sexp.drop(1).map { |s| translate_generic_sexp s }
       filtered_stmts(*sexps).with_value_sexp sexps.last.value_sexp
    end

    def translate_const(sexp)
       s().with_value(sexp[1], sexp[1])
    end

    private

    # Sets the parent-child class relationship in the symbol table.
    def set_parent(sexp)
      raise 'Only constant inheritance is allowed' if sexp[2][0] != :const
      @symbol_table.set_parent sexp[1], sexp[2][1]
    end
  end
end
