require 'sexp_parsing'
require 'extensions'
require 'optimizations/connection_graph_builder/local_table'
require 'optimizations/connection_graph_builder/connection_graph'
require 'optimizations/connection_graph_builder/stdlib_graphs'
require 'optimizations/connection_graph_builder/stdlib_graphs_loader'

# This class analyzes C ast code streamed by TranslationStreamer
# and builds connection graph abstraction for it.
#
# TODO: nil, constructors with params!
class ConnectionGraphBuilder 

   include SexpParsing

   attr_reader :local_table

   SymbolTableEvents = [:block_opened, :block_closed, :function_opened,
      :function_closed, :cfunction_changed]

   TranslatorEvents = [:lasgn_translated, :iasgn_translated, :attrasgn_translated,
      :cvasgn_translated, :cvdecl_translated, :lit_translated, :str_translated,
      :lvar_translated, :ivar_translated, :cvar_translated, :call_translated,
      :return_translated, :self_translated, :block_translated, :array_translated,
      :hash_translated, :if_translated, :case_translated, :class_translated]

   def initialize(translator)
      @s_table = translator.symbol_table
      @local_table = LocalTable.new
      @local_table.cfunction = @s_table.cfunction

      @key_counters = Hash.new(0)

      SymbolTableEvents.each do 
         |event| @s_table.subscribe(event, self.method(event))
      end

      TranslatorEvents.each do 
         |event| translator.subscribe(event, self.method(event)) 
      end

      # Load stdlib graphs.
      graph_loader = StdlibGraphsLoader.new(self)
      StdlibGraphs.each { |g| graph_loader.load(g) }
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
      # TODO: This is rather not elegant, since every function is translated twice.
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
         @local_table.assure_existence(formal_param, ConnectionGraph::PhantomNode,
                                      :arg_escape)
         @local_table.formal_params << formal_param
         @local_table.last_graph.add_edge(arg, formal_param)
         p_no += 1
      end
   end

   def block_translated(event)
      add_graph_node(event.original_sexp, event.original_sexp.last.graph_node)
   end

   def function_closed(event)
      n_function = @local_table.cfunction
      @local_table.cfunction = event.function
   
      defn = @s_table.class_table[:functions][event.function][:def]
      unless (last_node = defn.last.last.graph_node).nil?
         @local_table.last_graph.add_edge(:return, last_node)
      end
      
      @local_table.formal_params.each { |p| @local_table.propagate_escape_state(p) }
      @local_table.class_vars.each { |p| @local_table.propagate_escape_state(p) }
      @local_table.propagate_escape_state(:return)

      @local_table.abstract_objects.each do |key|
         o = @local_table.get_var_node(key)
         if o.escape_state == :no_escape
            o.constructor_sexp[1] = :SMALLOC
         end
      end

      @local_table.cfunction = n_function
   end

   def lasgn_translated(event)
      var = lasgn_get_var(event.original_sexp)
      @local_table.assure_existence(var)
      rsexp = lasgn_get_right(event.original_sexp)
      @local_table.by_pass(var)
      @local_table.last_graph.add_edge(var, rsexp.graph_node)
      add_graph_node(event.original_sexp, var)
   end
  
   def iasgn_translated(event)
      var = iasgn_get_var(event.original_sexp)
      var = "self_#{var}".to_sym
      @local_table.assure_existence(var, ConnectionGraph::FieldNode)
      @local_table.assure_existence(:self, ConnectionGraph::PhantomNode)
      rsexp = iasgn_get_right(event.original_sexp)
      @local_table.by_pass(var)
      @local_table.last_graph.add_edge(var, rsexp.graph_node)
      @local_table.last_graph.add_edge(:self, var)
      add_graph_node(event.original_sexp, var)
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
      add_graph_node(event.original_sexp, var)
   end

   alias :cvasgn_translated :cvdecl_translated 

   def return_translated(event)
      return if event.original_sexp.length == 1
   
      @local_table.assure_existence(:return)
      rsexp = return_get_right(event.original_sexp)
      @local_table.last_graph.add_edge(:return, rsexp.graph_node) if rsexp.graph_node
   end

   # Creates new object node.
   def create_new_object(event)
      obj_node = ConnectionGraph::ObjectNode.new
      obj_node.constructor_sexp =
         extract_constructor_call(event.translated_sexp)
      obj_node.type = event.translated_sexp.value_type 
      obj_key = next_key(:o)
      @local_table.abstract_objects << obj_key
      @local_table.last_graph[obj_key] = obj_node
      add_graph_node(event.original_sexp, obj_key)
   end

   alias :lit_translated :create_new_object
   alias :str_translated :create_new_object

   def array_translated(event)
      create_new_object(event)
      
      aid = event.original_sexp.graph_node
      a_node = @local_table.get_var_node(aid)
      fid = "#{aid}_[]".to_sym
      unless a_node.out_edges.include? fid
         @local_table.assure_existence(fid, ConnectionGraph::FieldNode)
         @local_table.last_graph.add_edge(aid, fid)
      end

      event.original_sexp.rest.map do |arg|
         arg_id = arg.graph_node
         @local_table.last_graph.add_edge(fid, arg_id) if arg_id
      end
   end

   def hash_translated(event)
      create_new_object(event)

      aid = event.original_sexp.graph_node
      a_node = @local_table.get_var_node(aid)
      fid = "#{aid}_[]".to_sym
      unless a_node.out_edges.include? fid
         @local_table.assure_existence(fid, ConnectionGraph::FieldNode)
         @local_table.last_graph.add_edge(aid, fid)
      end

      event.original_sexp.rest.map do |arg|
         arg_id = arg.graph_node
         @local_table.last_graph.add_edge(fid, arg_id)
      end
   end

   def if_translated(event)
      if_key = next_key(:c)
      @local_table.assure_existence(if_key)
      
      if (n = event.original_sexp[2]) and n.graph_node
         @local_table.copy_var_node(n.graph_node)
         @local_table.last_graph.add_edge(if_key, n.graph_node)
      end
      if (n = event.original_sexp[3]) and n.graph_node
         @local_table.copy_var_node(n.graph_node)
         @local_table.last_graph.add_edge(if_key, n.graph_node)
      end

      add_graph_node(event.original_sexp, if_key)
   end

   def case_translated(event)
      case_key = next_key(:c)
      @local_table.assure_existence(case_key)

      event.original_sexp.rest.find_all { |s| s.first == :when }.each do |s|
         if (n = s[2].graph_node)
            @local_table.copy_var_node(n)
            @local_table.last_graph.add_edge(case_key, n)
         end
      end
      unless event.original_sexp.last == :when
         if (n = event.original_sexp.last.graph_node)
            @local_table.copy_var_node(n)
            @local_table.last_graph.add_edge(case_key, n)
         end
      end

      add_graph_node(event.original_sexp, case_key)
   end

   # We can assume that class contains expression returning an object.
   def class_translated(event)
      obj_key = next_key(:cl)
      @local_table.assure_existence(obj_key, ConnectionGraph::ObjectNode)
      add_graph_node(event.original_sexp, obj_key)
   end

   def call_translated(event)
      if call_get_method(event.original_sexp) == :new
         create_new_object(event)
      else
         # Recursive calls are not really modelled until their type is determined.
         if event.translated_sexp.value_type == :recur
            obj_key = next_key(:recur)
            @local_table.assure_existence(obj_key, ConnectionGraph::PhantomNode)
            add_graph_node(event.original_sexp, obj_key)
            return
         end
         
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
      f_args = @local_table[f_name][:formal_params]
      mapping = Hash[ f_args.zip(a_args) ]
      
      # Update arguments 
      mapping.each_pair do |f_arg, a_arg|
         # TODO: Occurs with class methods, should be handled some other way.
         next if a_arg.nil?

         @local_table.points_to_set(a_arg).each do |a_obj|
            update_obj_node(a_obj, f_arg, f_name, mapping)
         end
      end

      # Model returned value
      #fun_key = "#{next_key(:f)}_#{f_name}"
      fun_key = next_key(:f)
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
         # TODO: Occurs with class methods, should be handled some other way.
         next if a_arg.nil?
        
         @local_table.points_to_set(a_arg).each do |a_obj|
            @local_table.get_var_node(a_obj).escape_state = :global_escape
         end
      end

      # Model returned value
      #f_name = translated_fun_name(event.translated_sexp)
      #fun_key = "#{next_key(:f)}_#{f_name}"
      fun_key = next_key(:f)
      @local_table.assure_existence(fun_key)
      obj_key = next_key(:o)
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

      a_node.escape_state = :global_escape if b_node.escape_state == :global_escape
      a_node.type = b_node.type if a_node.type.nil?

      b_node.out_edges.each do |b_fid|
         a_fid = "#{a}_#{strip_prefix(b_fid.to_s)}".to_sym
         unless a_node.out_edges.include? a_fid 
            @local_table.copy_var_node(a)
            @local_table.assure_existence(a_fid, ConnectionGraph::FieldNode)
            @local_table.last_graph.add_edge(a, a_fid)
         end

         update_ref_node(a_fid, b_fid, b_fun, mapping)
      end
   end

   # a -- caller reference
   # b -- callee reference
   # b_fun -- callee function
   def update_ref_node(a_fid, b_fid, b_fun, mapping)
      p_set = @local_table.points_to_set(b_fid, b_fun)

      # If there are no PhantomFields attached to b_fid, all previous values of
      # a_fid should be dropped.
      has_phantom = false
      p_set.each do |b|
        if @local_table.get_var_node(b, b_fun).is_a? ConnectionGraph::PhantomField
           has_phantom = true
        end
      end
      unless has_phantom
         @local_table.get_var_node(a_fid).out_edges.each do |out|
            @local_table.copy_var_node(a_fid)
            @local_table.copy_var_node(out)
            @local_table.last_graph.delete_edge(a_fid, out)
         end
      end

      # Assure existence of mapped object in a_fun and update their nodes.
      p_set.each do |ob|
         # Map ob to corresponding object in caller function.
         maps_to_set(ob, b_fun, mapping).each do |oa|
            unless @local_table.points_to_set(a_fid).include? oa
               @local_table.copy_var_node(a_fid)
               @local_table.assure_existence(oa, ConnectionGraph::ObjectNode)
               @local_table.last_graph.add_edge(a_fid, oa)
            end
            update_obj_node(oa, ob, b_fun, mapping)
         end
      end 
   end

   # Returns a set of object from current function to with an object ob from function
   # b_fun maps with certain mapping given.
   def maps_to_set(ob, b_fun, mapping)
      ob_node = @local_table.get_var_node(ob, b_fun)
      if ob_node.is_a? ConnectionGraph::PhantomField
         p = ob_node.parent_field
         po = get_prefix(p.to_s).to_sym
         s = []
         maps_to_set(po, b_fun, mapping).each do |a|
            a_node = @local_table.get_var_node(a)
            a_fid = "#{a}_#{strip_prefix(p.to_s)}".to_sym

            unless a_node.out_edges.include? a_fid 
               @local_table.assure_existence(a_fid, ConnectionGraph::FieldNode)
               @local_table.last_graph.add_edge(a, a_fid)
            end

            unless (a_fid_set = @local_table.points_to_set(a_fid)).empty?
               s = s + a_fid_set
            else
               ph = next_key(:ph)
               @local_table.assure_existence(ph, ConnectionGraph::PhantomField)
               @local_table.last_graph.add_edge(a_fid, ph)
               @local_table.get_var_node(ph).parent_field = a_fid
               s << ph
            end
         end
         return s
      elsif ob_node.is_a? ConnectionGraph::ObjectNode
         if mapping.include? ob
            return @local_table.points_to_set(mapping[ob])
         else
            @local_table.assure_existence(ob, ConnectionGraph::ObjectNode)
            return [ob]
         end
      end
   end

   def strip_prefix(f)
      f.gsub(/^.*?_/, '')
   end

   def get_prefix(f)
      f.match(/^(.*?)_/)[1]
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
      @local_table.assure_existence(var_id, ConnectionGraph::FieldNode)
      @local_table.assure_existence(:self, ConnectionGraph::PhantomNode)
      @local_table.last_graph.add_edge(:self, var_id)
      add_graph_node(event.original_sexp, var_id)

      if @local_table.points_to_set(var_id).empty?
         ph_id = next_key(:ph)
         @local_table.assure_existence(ph_id, ConnectionGraph::PhantomField,
                                       :arg_escape)
         @local_table.get_var_node(ph_id).parent_field = var_id
         @local_table.last_graph.add_edge(var_id, ph_id)
      end
   end

   def cvar_translated(event)
      var_id = event.original_sexp[1]
      @local_table.assure_existence(var_id)
      add_graph_node(event.original_sexp, var_id)
      
      if @local_table.points_to_set(var_id).empty?
         ph_id = next_key(:ph)
         @local_table.assure_existence(ph_id, ConnectionGraph::PhantomNode,
                                       :global_escape)
         @local_table.last_graph.add_edge(var_id, ph_id)
      end
   end

   ### END - Translator events handlers ###

   # Returns an unique id for requested id class.
   def next_key(cl)
      @key_counters[cl] += 1
      # Every node not representing Ruby variable should be prefixed with >'<
      "'#{cl}#{@key_counters[cl]}".to_sym
   end

   # Extracts actual constructor call from translated sexp.
   def extract_constructor_call(sexp)
      find_alloc = lambda do |s|
         return unless s.is_a? Sexp 
         if s[0] == :call and (s[1] == :xmalloc or s[1] == :xmalloc_atomic)
            s
         else
            s.each do |se|
               res = find_alloc.call(se)
               if res.is_a? Sexp
                  return res
               end
            end
            return
         end
      end

      find_alloc.call(sexp)
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
