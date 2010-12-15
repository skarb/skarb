class Translator
  # A module consisting of functions which handle C structure representing
  # classes.
  module ClassesDictionary
    # Generates definition of class dictionary and initializes it with
    # values from @symbol_table.
    def generate_dict_init
      sorter = lambda { |x,y| x[1][:id] <=> y[1][:id] }
      mapper = lambda do |k|
        # TODO: replace with real values
        if @symbol_table[k[1][:parent]] == k[0]
          parent_id = -1
        else
          parent_id = @symbol_table[k[1][:parent]][:id]
        end
        s(:init_block, s(:lit, parent_id),
          s(:var, ('mtab_'+k[0].to_s).to_sym),
            s(:lit, :NULL))
      end
      elem_inits = @symbol_table.each.sort(&sorter).map(&mapper)
      s(:asgn, s(:decl, :dict_elem, :'classes_dictionary[]'),
        s(:init_block, *elem_inits))
    end

    # Generates a structure of an element of the class dictionary.
    def generate_elem_struct
      structure_definition =
        s(:typedef,
          s(:struct, nil,
            s(:block,
              s(:decl, :uint32_t, :parent),
              s(:decl, :'void**', :method_table),
              s(:decl, :'void*', :fields_table))), :dict_elem)
    end

    # Generates class methods arrays declarations and initilizes it according
    # to @symbol_table.
    def generate_methods_arrays
      @symbol_table.each.map do |cname, chash|
        if chash.has_key?(:functions_def)
          methods_init = chash[:functions_def].each.map do |fname, fdef|
            if fdef.class == Sexp
              types = fdef[2].rest.map { nil }
              impl_name = mangle(fname, cname, types)
              unless function_implemented? impl_name
                @symbol_table.in_class cname do
                  implement_function impl_name, fdef, types
                end
              end
              s(:var, ('&'+impl_name.to_s).to_sym)
            else
              s(:var, ('&'+fdef.to_s).to_sym) 
            end
          end
        else
          methods_init = []
        end
        s(:asgn,
         s(:decl, :'void*', ('mtab_'+cname.to_s+'[]').to_sym),
         s(:init_block, *methods_init))
      end
    end
  end
end
