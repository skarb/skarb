require 'sexp_parsing'
require 'extensions'
require 'optimizations/memory_allocator/node'

# Class responsible for optimising memory allocation through stack allocation.
class MemoryAllocator 

   include SexpParsing

   def initialize(symbol_table)
      @symbol_table = symbol_table
      @abstract_objects = []
   end

   def lasgn_translated(event)
      var = lasgn_get_var(sexp)
      rsexp = lasgn_get_right(event.original_sexp)
      case rsexp[0]
      when :call
         if call_get_method(rsexp) == :new
            obj_node = ObjectNode.new
            obj_node.constructor_sexp =
               extract_constructor_call(event.translated_exp)
            @abstract_objects << obj_node
            var_hash = @symbol_table.get_lvar(var)
            var_hash[:cgraph_node] ||= Node.new
            var_hash[:cgraph_node].add_out_edge(obj_node) 
         end
      end
   end

   # Extracts actual constructor call from translated sexp
   def extract_constructor_call(sexp)
      # TODO: check if it really works ;)
      sexp[1].last[2]
   end

end
