require 'sexp_parsing'
require 'extensions'
require 'optimizations/connection_graph_builder/local_table'
require 'optimizations/connection_graph_builder/connection_graph'

# This class analyzes C ast code streamed by TranslationStreamer
# and builds connection graph abstraction for it.
#
# TODO: Model implicit return.
class ConnectionGraphBuilder 

   include SexpParsing

   attr_reader :local_table

   SymbolTableEvents = [:block_opened, :block_closed, :function_opened,
      :function_closed, :cfunction_changed]

   TranslatorEvents = [:lasgn_translated, :iasgn_translated, :attrasgn_translated,
      :cvasgn_translated, :cvdecl_translated, :lit_translated, :str_translated,
      :lvar_translated, :ivar_translated, :cvar_translated, :call_translated,
      :return_translated, :self_translated]

   def initialize(translator)
      @s_table = translator.symbol_table
      @local_table = LocalTable.new
      @local_table.cfunction = @s_table.cfunction

      @obj_counter = 0
      @fun_counter = 0

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
      # If function was already translated, its connection graph has to be reseted.
      if @local_table.formal_params.length > 0
         @local_table.add_function(@local_table.cfunction)
      end

      defn = @s_table.function_table[:def]
      args = defn_get_args(defn)
      p_no = 1
      @local_table.formal_params << :self
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
      var = "self_#{var}".to_sym
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
      else
         f_name = translated_fun_name(event.translated_sexp)

         caller_obj = call_get_object(event.original_sexp)
         add_graph_node(caller_obj, :self) if caller_obj.nil?
         a_args = ([caller_obj] +
                   call_get_args(event.original_sexp)).map { |a| a.graph_node }

         if f_name.is_a? Symbol and @local_table.has_key? f_name
            known_function_call(f_name, a_args, event)
         else
            unknown_function_call(a_args, event)
         end

      end
   end

   alias :attrasgn_translated :call_translated
 
   # When function with known connection graph is called, connection graph
   # of the caller is updated basing on the connection graph of the callee.
   # Arguments escape states need to be updated as well as they field structure.
   # Return value is modeled as single reference node pointing to an object.
   def known_function_call(f_name, a_args, event)
      # TODO: Set escape states of arguments
      f_args = @local_table[f_name][:formal_params]
      mapping = Hash[ f_args.zip(a_args) ]
      
      # Update arguments 
      mapping.each_pair do |f_arg, a_arg|
         @local_table.points_to_set(a_arg).each do |a_obj|
            update_obj_node(a_obj, f_arg, f_name, mapping)
         end
      end

      # Model returned value
      fun_key = next_fun_key
      @local_table.assure_existence(fun_key)
      update_ref_node(fun_key, :return, f_name, mapping)
      add_graph_node(event.original_sexp, fun_key)
   end

   # When function with unknown connection graph is called, we have to
   # pessimistically assume that all the arguments get global escape status.
   # Return value is modeled as single reference pointing to a newly created
   # object with global escape status.
   def unknown_function_call(a_args, event)
      # Set escape state of arguments as :global_escape
      a_args.each do |a_arg|
         @local_table.points_to_set(a_arg).each do |a_obj|
            @local_table.get_var_node(a_obj).escape_state = :global_escape
         end
      end

      # Model returned value
      fun_key = next_fun_key
      @local_table.assure_existence(fun_key)
      obj_key = next_obj_key
      @local_table.assure_existence(obj_key, ConnectionGraph::ObjectNode,
                                    :global_escape)
      @local_table.last_graph.add_edge(fun_key, obj_key)
      add_graph_node(event.original_sexp, fun_key)
   end

   # a -- caller object
   # b -- callee object (possibly phantom)
   # b_fun -- callee function
   def update_obj_node(a, b, b_fun, mapping)
      a_node = @local_table.get_var_node(a)
      b_node = @local_table.get_var_node(b, b_fun)

      b_node.out_edges.each do |b_fid|
         a_fid = "#{a}_#{strip_prefix(b_fid.to_s)}".to_sym
         unless a_node.out_edges.include? a_fid 
            @local_table.assure_existence(a_fid)
            @local_table.last_graph.add_edge(a, a_fid)
         end

         update_ref_node(a_fid, b_fid, b_fun, mapping)
      end
   end

   # a -- caller reference
   # b -- callee reference
   # b_fun -- callee function
   def update_ref_node(a_fid, b_fid, b_fun, mapping)
      @local_table.points_to_set(b_fid, b_fun).each do |ob|
         # Map ob to corresponding object in caller function.
         oa = (mapping.has_key? ob) ? mapping[ob] : ob

         unless @local_table.points_to_set(a_fid).include? oa
            @local_table.assure_existence(oa, ConnectionGraph::ObjectNode)
            @local_table.last_graph.add_edge(a_fid, oa)
         end
         update_obj_node(oa, ob, b_fun, mapping)
      end 
   end

   def strip_prefix(f)
      f.gsub(/^.*?_/, '')
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

   def ivar_translated(event)
      var_id = "self_#{event.original_sexp[1]}".to_sym
      @local_table.assure_existence(var_id)
      add_graph_node(event.original_sexp, var_id)
   end

   alias :cvar_translated :lvar_translated

   ### END - Translator events handlers ###

   # Returns an unique id for newly allocated object node.
   def next_obj_key
      @obj_counter += 1
      # Every node not representing Ruby variable should be prefixed with >'<
      "'o#{@obj_counter}".to_sym
   end

   # Returns an unique id for value returned from function.
   def next_fun_key
      @fun_counter += 1
      # Every node not representing Ruby variable should be prefixed with >'<
      "'f#{@fun_counter}".to_sym
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
