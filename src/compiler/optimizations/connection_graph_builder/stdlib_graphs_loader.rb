require 'sexp_parsing'
require 'extensions'
require 'optimizations/connection_graph_builder/connection_graph'

# This class loads descriptions of stdlib function connection
# graphs and stores them in local table.
class StdlibGraphsLoader

   def initialize(graph_builder)
      @graph_builder = graph_builder
      @local_table = graph_builder.local_table
   end

   def load(graph_sexp)
      function_name = graph_sexp[1]
      old_function = @local_table.cfunction
      @local_table.cfunction = function_name

      # Model params.
      @local_table.formal_params << :self
      args = graph_sexp.find_node(:args)
      if args
         args.rest.each do |arg|
            @local_table.assure_existence(arg, ConnectionGraph::PhantomNode,
                                          :arg_escape)
            @local_table.formal_params << arg
         end
      end

      mapping = Hash.new { |hash, key| key }

      # Model objects created in the function.
      new_objs = graph_sexp.find_node(:new_objects)
      if new_objs
         new_objs.rest.each do |new_obj|
            mapping[new_obj] = @graph_builder.next_key(:o)
            @local_table.assure_existence(mapping[new_obj],
                                          ConnectionGraph::ObjectNode, :arg_escape)
         end
      end
    
      # Model phantom field objects referenced in the function.
      ph_fields = graph_sexp.find_node(:phantom_fields)
      if ph_fields
         ph_fields.rest.each do |ph_obj|
            mapping[ph_obj] = @graph_builder.next_key(:ph)
            @local_table.assure_existence(mapping[ph_obj],
                                          ConnectionGraph::PhantomField, :arg_escape)
         end
      end

      # Set global escape state of selected objects.
      g_esc = graph_sexp.find_node(:global_escape)
      if g_esc
         g_esc.rest.each do |esc_obj|
            @local_table.last_graph[mapping[esc_obj]].escape_state = :global_escape
         end 
      end
     
      # Model graph edges. All previously undeclared nodes are treated as fields. 
      graph_sexp.find_node(:graph_edges).rest.each do |edge|
         a = mapping[edge[0]]
         b = mapping[edge[1]]
         @local_table.assure_existence(a, ConnectionGraph::FieldNode)
         @local_table.assure_existence(b, ConnectionGraph::FieldNode)
         @local_table.last_graph.add_edge(a, b)
      end 

      # Propagate global_escape state (all other objects have arg_escape state).
      if g_esc
         g_esc.rest.each { |esc| @local_table.propagate_escape_state(esc) }
      end

      @local_table.cfunction = old_function
   end

end
