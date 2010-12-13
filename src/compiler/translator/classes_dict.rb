class Translator
  # A module consisting of functions which handle C structure representing
  # classes.
  module ClassesDictionary
    # Generates definition of class dictionary and initializes it with
    # values from @symbol_table.
    def generate_dict_init
      sorter = lambda { |x,y| x[:id] <=> y[:id] }
      mapper = lambda do |val|
        # TODO: replace with real values
        s(:init_block, s(:lit, 0), s(:lit, :NULL), s(:lit, :NULL))
      end
      elem_inits = @symbol_table.each_value.sort(&sorter).map(&mapper)
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
              s(:decl, :'void*', :method_table),
              s(:decl, :'void*', :fields_table))), :dict_elem)
    end

  end
end
