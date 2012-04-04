require 'optimizations/memory_allocator/connection_graph'

class MemoryAllocator
   # Local symbol table for MemoryAllocator purposes. It stores connection graph
   # nodes organized by class, function and block (just like in global symbol
   # table used by translator).
   #
   # Rule: information from upper blocks can be used but modifications are made
   # only to last block. Upper blocks are updated when their children are closed.
   class LocalTable < Hash
      
      attr_reader :cclass, :cfunction
 
      # Synchronizes current class and function with another symbol table. 
      def synchronize(symbol_table) 
         self.cclass = symbol_table.cclass
         self.cfunction = symbol_table.cfunction
      end

      # Adds new function in current class context with mandatory keys.
      def add_function(f_name)
         self[@cclass][f_name] = {
            :vars => ConnectionGraph.new,
            :parent => nil
         }
      end

      # Adds new class with mandatory keys.
      def add_class(class_name)
         self[class_name] = {} 
      end

      # Adds key-node pair to the last open block.
      def add_node(key, node)
         last_block[:vars][key] = node
      end

      # Current class setter. Creates new class if necessary.
      def cclass=(class_name)
         @cclass = class_name
         add_class(@cclass) unless self.has_key? @cclass
      end

      # Current function setter. Creates new function if necessary.
      def cfunction=(f_name)
         @cfunction = f_name
         add_function(@cfunction) unless self[@cclass].has_key? @cfunction
      end

      # Opens new block representing conditional program branch.
      def open_block
         self.last_block = { :vars => ConnectionGraph.new, :parent => last_block }
      end

      # Closes block and merges conditional branches by merging nodes of
      # corresponding variables.
      def close_block
         old_block = last_block
         self.last_block = last_block[:parent]

         old_block[:vars].each do |key, old_node|
            node = copy_var_node(key)
            if node.nil?
               last_block[:vars][key] = old_node
            else
               # The nodes are merged if their outgoing edges differ.
               if !(node.out_edges == old_node.out_edges)
                  # Partial by pass of node:
                  node.in_edges.each do |from_vert|
                     copy_var_node(from_vert)
                     node.out_edges.each do |to_vert|
                        copy_var_node(to_vert)
                        last_block[:vars].add_edge(from_vert, to_vert)
                     end
                     last_block[:vars].delete_edge(from_vert, key)
                  end

                  # Partial by pass of the old node:
                  old_node.in_edges.each do |from_vert|
                     copy_var_node(from_vert) ||
                        (last_block[:vars][from_vert] = old_block[:vars][from_vert])
                     old_node.out_edges.each do |to_vert|
                        copy_var_node(to_vert) ||
                           (last_block[:vars][to_vert] = old_block[:vars][to_vert])
                        last_block[:vars].add_edge(from_vert, to_vert)
                     end
                     last_block[:vars].delete_edge(from_vert, key)
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
         self[@cclass][@cfunction]
      end

      # Connection graph associated with last block.
      def last_graph
         self[@cclass][@cfunction][:vars]
      end

      # Last opened block setter.
      def last_block=(val)
         self[@cclass][@cfunction] = val
      end

      # Searches for variable by traversing up the block structure and
      # returns graph node corresponding to it. If no node can be found nil
      # is returned. Key can be :lvars, :ivars or :cvars.
      def get_var_node(var)
         cblock = last_block
         begin
            return cblock[:vars][var] if cblock[:vars].has_key? var
            cblock = cblock[:parent]
         end until cblock.nil?
         nil
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
      def assure_existence(var)
         copy_var_node(var) || (last_graph[var] = ConnectionGraph::Node.new)
      end

   end
end
