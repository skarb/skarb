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
                      s(:block, *fields_declarations)), class_name)
      @structures_definitions[class_name] = structure_definition
    end

    def class_constructor(class_name, constructor_name, init_args=[], init_body=[])
      s(:defn, :'Object*', constructor_name, s(:args, *init_args),
        s(:block,
          s(:asgn,
          s(:decl, :'Object*', :self),
          s(:call, :xmalloc,
            s(:args, s(:call, :sizeof, s(:args, s(:lit, class_name)))))),
          *init_body,
          s(:return, s(:var, :self))))
    end

    # Translates class definition.
    def translate_class(sexp)
      class_name=sexp[1]
      parent_class=sexp[2]
      higher_class=@symbol_table.cclass
      @symbol_table.cclass=class_name
      body = translate_generic_sexp(sexp[3])

      @symbol_table.cclass=higher_class
      @user_classes << class_name
      # TODO: Build main function for class
      s()
      #s(:stmts, *body)
    end

    def translate_scope(sexp)
       sexps = sexp.drop(1).map { |s| translate_generic_sexp s }
       filtered_stmts(*sexps).with_value_sexp sexps.last.value_sexp
    end

    def translate_const(sexp)
       s().with_value(sexp[1], sexp[1])
    end
  end
end
