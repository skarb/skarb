require 'hash_builder'

# This class contains tools used to construct C static structures for storing
# information about classes -- their methods, static fields etc.
class ClassesDictionaryBuilder
  class << self
    # Generates full code for classes dictionary. Returns code splitted
    # in structs, prototypes, methods and global variables + main
    def emit_classes_dictionary(symbol_table)
      [nil, nil,
        emit_methods_arrays(symbol_table),
        emit_dict_init(symbol_table)]
    end

    private  

    # Generates definition of class dictionary and initializes it with
    # values from @symbol_table.
    def emit_dict_init(symbol_table)
      sorter = lambda { |x,y| x[1][:id] <=> y[1][:id] }
      mapper = lambda do |k|
        # TODO: replace with real values
        if symbol_table[k[1][:parent]] == k[0]
          parent_id = -1
        else
          parent_id = symbol_table[k[1][:parent]][:id]
        end
        if k[1].has_key? :functions_def and not k[1][:functions_def].empty?
          msearch = s(:var, ('&'+k[0].to_s+"_method_find").to_sym)
        else
          msearch = s(:lit, :NULL)
        end
        s(:init_block, s(:lit, parent_id),
          msearch,
          s(:lit, :NULL))
      end
      elem_inits = symbol_table.each.sort(&sorter).map(&mapper)
      Emitter.emit(s(:file, s(:asgn, s(:decl, :dict_elem, :'classes_dictionary[]'),
                     s(:init_block, *elem_inits))))
    end

    # Generates declaration of dict_elem structure
    def emit_dict_elem_struct
      "typedef struct {
      int parent;
      hash_elem* (*msearch)(char*,unsigned int);
      void* fields; } dict_elem;"
    end

    # Generates class methods hashes.
    def emit_methods_arrays(symbol_table)
      symbol_table.map do |cname, chash|
        if chash.has_key? :functions_def
          id2fun_pairs = chash[:functions_def].map do |fname,fdef|
            if fdef.class == Sexp
              suffix = '_' * fdef[2].rest.length
              [symbol_table.fname_id(fname),
                ('&'+cname.to_s+'_'+fname.to_s+suffix).to_sym]
            else
              # Method defined in stdlib
              [symbol_table.fname_id(fname), ('&'+fdef.to_s).to_sym]
            end 
          end
          HashBuilder.emit_table(cname, id2fun_pairs)
        end
      end.join
    end
  end
end
