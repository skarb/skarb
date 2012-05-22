require 'optimizations/connection_graph_builder/connection_graph'

class ConnectionGraphBuilder
   # Local symbol table for ConnectionGraphBuilder purposes. It stores connection
   # graph nodes organized by function and block (natural structure of C code).
   #
   # Rule: information from upper blocks can be used but modifications are made
   # only to last block. Upper blocks are updated when their children are closed.
   class LocalTable < Hash
      
      FunctionStruct = Struct.new(:last_block, :formal_params, :class_vars,
                                  :abstract_objects)
      BlockStruct = Struct.new(:vars, :parent)

      attr_reader :cfunction

      # Adds new function in current class context with mandatory keys.
      def add_function(f_name)
         self[f_name] = FunctionStruct.new(BlockStruct.new(
            ConnectionGraph.new, nil), [], [], [])
         assure_existence(:return, ConnectionGraph::Node, :arg_escape)
         assure_existence(:self, ConnectionGraph::PhantomNode, :arg_escape)
      end

      # Adds key-node pair to the last open block.
      def add_node(key, node)
         last_block[:vars][key] = node
      end

      # Current function setter. Creates new function if necessary.
      def cfunction=(f_name)
         @cfunction = f_name
         add_function(@cfunction) unless self.has_key? @cfunction
      end

      # Opens new block representing conditional program branch.
      def open_block
         self.last_block = BlockStruct.new(ConnectionGraph.new, last_block)
      end

      # Closes block and merges conditional branches by merging nodes of
      # corresponding variables.
      # TODO: Refactor this monster!
      def close_block
         old_block = last_block
         self.last_block = last_block[:parent]

         old_block[:vars].each do |key, old_node|
            node = copy_var_node(key)
            if node.nil?
               last_block[:vars][key] = old_node
            else
               # The nodes are merged if their outgoing edges differ.
               if node.out_edges != old_node.out_edges
                  
                  if node.class == ConnectionGraph::Node

                     # Partial by pass of the node:
                     node.in_edges.each do |from_vert|
                        # We want to by pass only reference edges, not field edges.
                        next if get_var_node(from_vert).class != ConnectionGraph::Node

                        copy_var_node(from_vert)
                        node.out_edges.each do |to_vert|
                           copy_var_node(to_vert)
                           last_block[:vars].add_edge(from_vert, to_vert)
                        end
                        last_block[:vars].delete_edge(from_vert, key)
                     end

                     # Partial by pass of the old node:
                     old_node.in_edges.each do |from_vert|
                        # We want to by pass only reference edges, not field edges.
                        f_node = get_var_node(from_vert) || old_block[:vars][from_vert]
                        next if f_node.class != ConnectionGraph::Node

                        copy_var_node(from_vert) ||
                           (last_block[:vars][from_vert] = old_block[:vars][from_vert])
                        old_node.out_edges.each do |to_vert|
                           copy_var_node(to_vert) ||
                              (last_block[:vars][to_vert] = old_block[:vars][to_vert])
                           last_block[:vars].add_edge(from_vert, to_vert)
                           old_block[:vars].add_edge(from_vert, to_vert)
                        end
                        last_block[:vars].delete_edge(from_vert, key)
                        old_block[:vars].delete_edge(from_vert, key)
                     end

                  end

                  # Copy old node out edges to the node:
                  old_node.out_edges.each do |to_vert|
                     copy_var_node(to_vert) ||
                        (last_block[:vars][to_vert] = old_block[:vars][to_vert])
                     last_block[:vars].add_edge(key, to_vert)
                  end
               end
            end
         end
      end

      # Updates the connection graph in last block by removing vertex from
      # the references chain.
      def by_pass(vertex)
         node = copy_var_node(vertex)
         return if node.nil? or node.is_a? ConnectionGraph::ObjectNode

         node.in_edges.each do |from_vert|
            # We want to by pass only reference edges, not field edges.
            next if get_var_node(from_vert).class != ConnectionGraph::Node
            
            copy_var_node(from_vert)
            node.out_edges.each do |to_vert|
               copy_var_node(to_vert)
               last_block[:vars].add_edge(from_vert, to_vert)
            end
            last_block[:vars].delete_edge(from_vert, vertex)
         end
         node.out_edges.clear
      end

      # Last opened block getter.
      def last_block
         self[@cfunction][:last_block]
      end

      # Connection graph associated with last block.
      def last_graph
         last_block[:vars]
      end

      # List of abstract objects allocated in this function.
      def abstract_objects
         self[@cfunction][:abstract_objects]
      end

      # List of formal parameters in this function.
      def formal_params
         self[@cfunction][:formal_params]
      end

      # List of class variables referenced in this function.
      def class_vars
         self[@cfunction][:class_vars]
      end

      # Last opened block setter.
      def last_block=(val)
         self[@cfunction][:last_block] = val
      end

      # Searches for variable by traversing up the block structure and
      # returns graph node corresponding to it. If no node can be found nil
      # is returned. Key can be :lvars, :ivars or :cvars.
      def get_var_node(var, function=@cfunction)
         ret = nil
         old_function = @cfunction
         @cfunction = function
         
         cblock = last_block
         begin
            if cblock[:vars].has_key? var
               ret = cblock[:vars][var]
               break
            end
            cblock = cblock[:parent]
         end until cblock.nil?
      
         @cfunction = old_function
         ret      
      end

      # Collects all object nodes and field nodes ids which are pointed to by var
      # node. It recursively follows deferred edges.
      # points_to_set(ref) returns pointed object or fields
      # points_to_set(object) returns object
      #
      def points_to_set(var, function=@cfunction)
         old_function = @cfunction
         @cfunction = function
         set = []

         update_set = Proc.new do |v|
            v_node = get_var_node(v)
            cg = ConnectionGraph
            if v_node.is_a? cg::ObjectNode
               set << v
            else
               v_node.out_edges.each { |u| update_set.call(u) }
            end
         end
         update_set.call(var)

         @cfunction = old_function
         set
      end

      # Copies variable node and places the copy in the last block. It is necessary
      # to do so before assigment to variable. Key can be :lvars, :ivars or :cvars.
      def copy_var_node(var)
         # If lvar is defined in the last block it is unnecessary to copy it's node.
         return last_block[:vars][var] if last_block[:vars].has_key? var
         if (node = get_var_node(var)).nil?
            nil
         else
            last_block[:vars][var] = node.clone
         end
      end

      # Copies variable node to the last block or create a new node if none exists.
      # First parameter is variable id, the second is new node type (normal Node
      # by default).
      def assure_existence(var, type = ConnectionGraph::Node, esc_state = :no_escape)
         copy_var_node(var) || (last_graph[var] = type.new(esc_state))
      end

      # Recursively propagate escape state down the connection graph starting from
      # certain node.
      def propagate_escape_state(var_a)
         node_a = get_var_node(var_a)
         node_a.out_edges.each do |var_b|
            node_b = get_var_node(var_b)
            node_b.escape_state = merge_escape_states(node_a.escape_state,
                                                   node_b.escape_state)
            propagate_escape_state(var_b)
         end
      end

      # Merges two escape states according to their hierarchy.
      def merge_escape_states(a, b)
         return :global_escape if a == :global_escape || b == :global_escape
         return :arg_escape if a == :arg_escape || b == :arg_escape
         return :no_escape
      end
   end
end
