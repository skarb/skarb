require 'hash_builder'

# This class contains tools used to construct C static structures for storing
# information about classes -- their methods, static fields etc.
class ClassesDictionaryBuilder
  # Constructor. Whole functionality of ClassesDictionaryBuilder relies
  # on final symbol table. 
  def initialize(symbol_table)
    @symbol_table = symbol_table
    @wrappers = {}
  end

  # Generates full code for classes dictionary. Returns code splitted
  # in structs, prototypes, methods and global variables + main
  def emit_classes_dictionary
    methods = emit_methods_arrays + emit_wrappers
    protos = emit_wrappers_protos
    [nil, protos, methods, emit_dict_init]
  end

  private  

  HashElemStruct = "hash_elem"

  # Generates definition of class dictionary and initializes it with
  # values from @symbol_table.
  def emit_dict_init
    selector = lambda { |k,v| v.has_key? :id }
    sorter = lambda { |x,y| x[1][:id] <=> y[1][:id] }
    mapper = lambda do |k|
      if k[1][:parent].nil?
        parent_id = -1
      else
        parent_id = @symbol_table.id_of k[1][:parent]
      end
      if k[1][:functions_def].nil? or k[1][:functions_def].empty?
        msearch = s(:lit, :NULL)
      else
        msearch = s(:var, ('&'+k[0].to_s+"_method_find").to_sym)
      end
      cvars = s(:var, ('&vs_'+k[0].to_s).to_sym)
      s(:init_block, s(:lit, parent_id),
        msearch, cvars)
    end
    elem_inits = @symbol_table.select(&selector).each.sort(&sorter).map(&mapper)
    Emitter.emit(s(:file, s(:asgn, s(:decl, :dict_elem, :'classes_dictionary[]'),
                            s(:init_block, *elem_inits))))
  end

  # Generates class methods hashes.
  def emit_methods_arrays
    @symbol_table.map do |cname, chash|
      if chash.has_key? :functions_def
        id2fun_records = chash[:functions_def].map do |fname,farray|
          farray.each do |fdef|
            args_number = fdef[2].rest.length
            # We have to count in 'self' argument
            add_wrapper (args_number+1) unless @wrappers.has_key? (args_number+1)
          end
          fdef = farray.first
          args_number = fdef[2].rest.length
          if fdef[0] == :stdlib_defn
            # Method defined in stdlib
            [fname, ('&'+fdef[1].to_s).to_sym, "&wrapper_#{args_number+1}".to_sym]
          else
            # Method defined in user code
            [fname, :NULL, :NULL]
          end 
        end
        HashBuilder.emit_table(cname, HashElemStruct, id2fun_records)
      end
    end.join
  end

  # Builds AST code for wrapper function with specified amount of
  # arguments and stores it in @wrappers
  def add_wrapper(n)
    @wrappers[n] =
      s(:static,
        s(:defn, :'Object*', ('wrapper_' + n.to_s).to_sym,
          s(:args, s(:decl, :'Object**', :args_tab),
            s(:decl, :'void*', :fun)),
          s(:block,
            s(:return,
              s(:call, 
                s(:cast,
                  ('Object* (*)('+n.times.map { 'Object*' }.join(',')+')').to_sym,
                  s(:var, :fun)),
                s(:args, *n.times.map { |x| s(:var, "args_tab[#{x}]") }))))))
  end

  # Generates function wrappers prototypes
  def emit_wrappers_protos
    Emitter.emit(
      s(:file,
        *@wrappers.values.map { |fun| s(:static, s(:prototype, *fun[1][1,3])) }))
  end

  # Generates wrappers definitions
  def emit_wrappers
    Emitter.emit(s(:file, *@wrappers.values))
  end
end
