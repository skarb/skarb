require 'sexp_parsing'
require 'extensions'
require 'optimizations/memory_allocator/local_table'
require 'optimizations/memory_allocator/connection_graph'

# Class responsible for optimising memory allocation through stack allocation.
# It main function is to build connection graphs for subsequent functions.
class MemoryAllocator 

   include SexpParsing

   attr_reader :local_table

   def initialize(translator)
      @s_table = translator.symbol_table
      @local_table = LocalTable.new
      @local_table.synchronize(@s_table)

      @obj_counter = 0

      @s_table.subscribe(:block_opened, self.method(:block_opened)) 
      @s_table.subscribe(:block_closed, self.method(:block_closed))
      @s_table.subscribe(:cclass_changed, self.method(:update_context)) 
      @s_table.subscribe(:cfunction_changed, self.method(:update_context))

      translator.subscribe(:lasgn_translated, self.method(:lasgn_translated)) 
      translator.subscribe(:iasgn_translated, self.method(:iasgn_translated)) 
      translator.subscribe(:cvdecl_translated, self.method(:cvdecl_translated)) 
   end

   ### BEGIN - Symbol table events handlers ###
   
   def update_context(event)
      @local_table.synchronize(@s_table)
   end

   def block_opened(event)
      @local_table.open_block
   end
   
   def block_closed(event)
      @local_table.close_block
   end
   
   ### END - Symbol table events handlers ###

   ### BEGIN - Translator events handlers ###

   def lasgn_translated(event)
      var = lasgn_get_var(event.original_sexp)
      @local_table.assure_existence(var)
      rsexp = lasgn_get_right(event.original_sexp)
      asgn_update(var, rsexp, event)
   end
  
   def iasgn_translated(event)
      var = iasgn_get_var(event.original_sexp)
      @local_table.assure_existence(var)
      @local_table.last_graph[var].escape_state = :instance
      rsexp = iasgn_get_right(event.original_sexp)
      asgn_update(var, rsexp, event)
   end

   def cvdecl_translated(event)
      var = cvdecl_get_var(event.original_sexp)
      @local_table.assure_existence(var)
      @local_table.last_graph[var].escape_state = :class
      rsexp = cvdecl_get_right(event.original_sexp)
      asgn_update(var, rsexp, event)
   end

   #def return_translated(event)
   #   return if event.original_sexp.length == 1
   #
   #   case event.original_sexp[1]
   #   when 
   #   end
   #end

   ### END - Translator events handlers ###

   # Performs connection graph update on assigment to variable.
   def asgn_update(var, rsexp, event)
      case rsexp[0]
      when :call
         if call_get_method(rsexp) == :new
            asgn_new_object(var, event)
         end
      when :lit, :str
         asgn_new_object(var, event)
      when :lvar, :ivar, :cvar
         @local_table.by_pass(var)
         @local_table.assure_existence(rsexp[1])
         @local_table.last_graph.add_edge(var, rsexp[1])
      end
   end

   # Create new object node and assign it to a variable.
   def asgn_new_object(var, event)
      obj_node = ConnectionGraph::ObjectNode.new
      obj_node.constructor_sexp =
         extract_constructor_call(event.translated_sexp)
      obj_key = next_obj_key
      @local_table.abstract_objects << obj_key
      @local_table.last_graph[obj_key] = obj_node
      @local_table.by_pass(var)
      @local_table.last_graph.add_edge(var, obj_key)
   end
   
   # Returns an unique id for newly allocated object node.
   def next_obj_key
      @obj_counter += 1
      # Every node not representing Ruby variable should be prefixed with '
      "'o#{@obj_counter}".to_sym
   end

   # Extracts actual constructor call from translated sexp.
   def extract_constructor_call(sexp)
      # TODO: check if it really works ;)
      sexp[1].last[2]
   end

end
