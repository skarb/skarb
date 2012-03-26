class MemoryAllocator
   # Class representing node in connection graph. Both in- and out- edges are 
   # represented but only out- edges can be added or deleted (symmetric in-
   # edges are modified automatically).
   class Node
      def initialize
         @out_edges = Set.new
         @in_edges = Set.new
         #@escape_state = :no_escape
      end

      attr_accessor :escape_state
      attr_reader :out_edges, :in_edges

      def add_out_edge(to)
         @out_edges << to
         to.add_in_edge(self)
      end

      def delete_out_edge(to)
         @out_edges.delete(to)
         to.delete_in_edge(self)
      end

      protected

      def add_in_edge(from)
         @in_edges << from
      end

      def delete_in_edge(from)
         @in_edges.delete(from)
      end
   end
   
   # Node representing abstract object; it has a reference to sexp with translated
   # constructor call.
   class ObjectNode << Node
      attr_accessor :constructor_sexp
   end
end
