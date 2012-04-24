require 'sexp_parsing'
require 'extensions'
require 'optimizations/memory_allocator/local_table'
require 'optimizations/memory_allocator/connection_graph'

# Class responsible for optimising memory allocation through stack allocation.
# It main function is to build connection graphs for subsequent functions.
class MemoryAllocator 

   include SexpParsing

   attr_reader :local_table

   SymbolTableEvents = [:block_opened, :block_closed, :function_opened, :function_closed, :cclass_changed, :cfunction_changed]
   TranslatorEvents = [:lasgn_translated, :iasgn_translated, :cvdecl_translated, :lit_translated,
      :str_translated, :lvar_translated, :ivar_translated, :cvar_translated, :call_translated, :return_translated]

   def initialize(translator)
      @s_table = translator.symbol_table
      @local_table = LocalTable.new
      @local_table.synchronize(@s_table)

      @obj_counter = 0

      SymbolTableEvents.each do 
         |event| @s_table.subscribe(event, self.method(event)) 
      end
      TranslatorEvents.each do 
         |event| translator.subscribe(event, self.method(event)) 
      end
   end

   ### BEGIN - Symbol table events handlers ###
   
   def update_context(event)
      @local_table.synchronize(@s_table)
   end

   alias :cclass_changed :update_context
   alias :cfunction_changed :update_context

   def block_opened(event)
      @local_table.open_block
   end
   
   def block_closed(event)
      @local_table.close_block
   end
 
   # Creates phantom node for each formal parameter and normal nodes for parameter
   # variables.
   def function_opened(event)
      defn = @s_table.function_def(@s_table.cclass, event.function)
      args = defn_get_args(defn)
      @local_table.assure_existence(:self)
      @local_table.formal_params << :self
      p_no = 1
      args.each do |arg|
         formal_param = "'p#{p_no}".to_sym
         @local_table.assure_existence(arg)
         @local_table.assure_existence(formal_param)
         @local_table.formal_params << formal_param
         @local_table.last_graph.add_edge(arg, formal_param)
         p_no += 1
      end
   end

   def function_closed(event)
      #p @s_table.class_table[:functions][event.function]
   end

   ### END - Symbol table events handlers ###

   ### BEGIN - Translator events handlers ###

   def lasgn_translated(event)
      var = lasgn_get_var(event.original_sexp)
      @local_table.assure_existence(var)
      rsexp = lasgn_get_right(event.original_sexp)
      asgn_update(var, rsexp)
   end
  
   def iasgn_translated(event)
      var = iasgn_get_var(event.original_sexp)
      @local_table.assure_existence(var)
      @local_table.last_graph[var].escape_state = :instance
      rsexp = iasgn_get_right(event.original_sexp)
      asgn_update(var, rsexp)
   end

   def cvdecl_translated(event)
      var = cvdecl_get_var(event.original_sexp)
      @local_table.assure_existence(var)
      @local_table.last_graph[var].escape_state = :class
      rsexp = cvdecl_get_right(event.original_sexp)
      asgn_update(var, rsexp)
   end

   def return_translated(event)
      return if event.original_sexp.length == 1
   
      @local_table.assure_existence(:return)
      rsexp = return_get_right(event.original_sexp)
      @local_table.last_graph.add_edge(:return, rsexp.graph_node)
   end

   # Creates new object node.
   def create_new_object(event)
      obj_node = ConnectionGraph::ObjectNode.new
      obj_node.constructor_sexp =
         extract_constructor_call(event.translated_sexp)
      obj_key = next_obj_key
      @local_table.abstract_objects << obj_key
      @local_table.last_graph[obj_key] = obj_node
      add_graph_node(event.original_sexp, obj_key)
   end

   def call_translated(event)
      if call_get_method(event.original_sexp) == :new
         create_new_object(event)
      end
   end

   alias :lit_translated :create_new_object
   alias :str_translated :create_new_object

   def lvar_translated(event)
      var_id = event.original_sexp[1]
      @local_table.assure_existence(var_id)
      add_graph_node(event.original_sexp, var_id)
   end

   alias :ivar_translated :lvar_translated
   alias :cvar_translated :lvar_translated

   ### END - Translator events handlers ###

   # Performs connection graph update on assigment to variable.
   def asgn_update(var, rsexp)
      @local_table.by_pass(var)
      @local_table.last_graph.add_edge(var, rsexp.graph_node)
   end
      
   # Returns an unique id for newly allocated object node.
   def next_obj_key
      @obj_counter += 1
      # Every node not representing Ruby variable should be prefixed with '
      "'o#{@obj_counter}".to_sym
   end

   # Extracts actual constructor call from translated sexp.
   def extract_constructor_call(sexp)
      # TODO: Debug; it doesn't work at all
      # sexp[1].last[2]
   end

   # Helper function. Dynamically adds an attribute with an id of the
   # connection graph node representing returned value to an arbitrary sexp.
   def add_graph_node(object, value)
      object.instance_variable_set(:@graph_node, value)
      def object.graph_node
         @graph_node
      end
   end

end
