require 'sexp_parsing'
require 'extensions'
require 'optimizations/connection_graph_builder/local_table'
require 'optimizations/connection_graph_builder/connection_graph'

# This class analyzes C ast code streamed by TranslationStreamer
# and builds connection graph abstraction for it.
class ConnectionGraphBuilder 

   include SexpParsing

   attr_reader :local_table

   SymbolTableEvents = [:block_opened, :block_closed, :function_opened,
      :function_closed, :cfunction_changed]

   TranslatorEvents = [:lasgn_translated, :iasgn_translated,
      :cvasgn_translated, :cvdecl_translated, :lit_translated, :str_translated,
      :lvar_translated, :ivar_translated, :cvar_translated, :call_translated,
      :return_translated, :self_translated]

   def initialize(translator)
      @s_table = translator.symbol_table
      @local_table = LocalTable.new
      @local_table.cfunction = @s_table.cfunction

      @obj_counter = 0

      SymbolTableEvents.each do 
         |event| @s_table.subscribe(event, self.method(event))
      end

      TranslatorEvents.each do 
         |event| translator.subscribe(event, self.method(event)) 
      end
   end

   def cfunction_changed(event)
      @local_table.cfunction = event.new_value
   end

   def block_opened(event)
      @local_table.open_block
   end
   
   def block_closed(event)
      @local_table.close_block
   end
 
   # Creates phantom node for each formal parameter and normal nodes for parameter
   # variables.
   def function_opened(event)
      defn = @s_table.function_table[:def]
      args = defn_get_args(defn)
      p_no = 1
      args.each do |arg|
         formal_param = "'p#{p_no}".to_sym
         @local_table.assure_existence(arg)
         @local_table.assure_existence(formal_param, ConnectionGraph::PhantomNode)
         @local_table.formal_params << formal_param
         @local_table.last_graph.add_edge(arg, formal_param)
         p_no += 1
      end
   end

   def function_closed(event)
      n_function = @local_table.cfunction
      @local_table.cfunction = event.function
   
      @local_table.formal_params.each { |p| @local_table.propagate_escape_state(p) }
      @local_table.class_vars.each { |p| @local_table.propagate_escape_state(p) }
      @local_table.propagate_escape_state(:return)

      @local_table.cfunction = n_function
   end

   def lasgn_translated(event)
      var = lasgn_get_var(event.original_sexp)
      @local_table.assure_existence(var)
      rsexp = lasgn_get_right(event.original_sexp)
      @local_table.by_pass(var)
      @local_table.last_graph.add_edge(var, rsexp.graph_node)
   end
  
   def iasgn_translated(event)
      var = iasgn_get_var(event.original_sexp)
      @local_table.assure_existence(var)
      @local_table.assure_existence(:self)
      rsexp = iasgn_get_right(event.original_sexp)
      @local_table.by_pass(var)
      @local_table.last_graph.add_edge(var, rsexp.graph_node)
      @local_table.last_graph.add_edge(:self, var)
   end

   def cvdecl_translated(event)
      var = cvdecl_get_var(event.original_sexp)
      @local_table.assure_existence(var)
      @local_table.class_vars << var
      node = @local_table.get_var_node(var)
      node.escape_state = :global_escape
      rsexp = cvdecl_get_right(event.original_sexp)
      @local_table.by_pass(var)
      @local_table.last_graph.add_edge(var, rsexp.graph_node)
   end

   alias :cvasgn_translated :cvdecl_translated 

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

   alias :lit_translated :create_new_object
   alias :str_translated :create_new_object
   
   def call_translated(event)
      if call_get_method(event.original_sexp) == :new
         create_new_object(event)
      end
   end

   def self_translated(event)
      @local_table.assure_existence(:self, ConnectionGraph::PhantomNode)
      add_graph_node(event.original_sexp, :self)       
   end

   def lvar_translated(event)
      var_id = event.original_sexp[1]
      @local_table.assure_existence(var_id)
      add_graph_node(event.original_sexp, var_id)
   end

   alias :ivar_translated :lvar_translated
   alias :cvar_translated :lvar_translated

   ### END - Translator events handlers ###

   # Returns an unique id for newly allocated object node.
   def next_obj_key
      @obj_counter += 1
      # Every node not representing Ruby variable should be prefixed with >'<
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
