# Class representing connection graph. It is a hash containing ids of the
# vertices. Under each key a node object is stored -- it contains outgoing
# and incoming edges sets as well as aditional properties.
class ConnectionGraph < Hash

   # Generic node in connection graph. 
   class Node
      attr_accessor :escape_state, :out_edges, :in_edges
      
      def initialize
         @out_edges = Set.new
         @in_edges = Set.new
         @escape_state = :no_escape
      end

      def initialize_copy
         super
         @out_edges = @out_edges.dup
         @in_edges = @in_edges.dup
      end

   end

   # Node representing abstract object; it has a reference to sexp with translated
   # constructor call.
   class ObjectNode < Node
      attr_accessor :constructor_sexp
   end

   def add_edge(from, to)
      self[from].out_edges << to
      self[to].in_edges << from
   end

   def delete_edge(from, to)
      self[from].out_edges.delete(to)
      self[to].in_edges.delete(from)
   end

end
   
