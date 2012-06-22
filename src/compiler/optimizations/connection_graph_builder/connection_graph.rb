require 'set'

# Class representing connection graph. It is a hash containing ids of the
# vertices. Under each key a node object is stored -- it contains outgoing
# and incoming edges sets as well as aditional properties.
#
# Convention: vertex means vertex id, node means associated node object.
class ConnectionGraph < Hash

   # Generic node in connection graph. 
   class Node
      attr_accessor :escape_state, :out_edges, :in_edges
      
      def initialize(esc_state = :no_escape)
         @out_edges = Set.new
         @in_edges = Set.new
         @escape_state = esc_state
      end

      def initialize_copy(src)
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

   # Node representing field of an object.
   class FieldNode < Node
   end

   # Node representing formal function parameter.
   class PhantomNode < ObjectNode
   end

   # Node representing unknown value of object field.
   class PhantomField < ObjectNode
      attr_accessor :parent_field
   end

   def add_edge(from_vertex, to_vertex)
      begin
         self[from_vertex].out_edges << to_vertex
         self[to_vertex].in_edges << from_vertex
      rescue NoMethodError => e
         err_suffix = "in add_edge(#{from_vertex}, #{to_vertex})."
         if self[from_vertex].nil?
            puts("No vertex with id #{from_vertex} " << err_suffix)
         else
            puts("No vertex with id #{to_vertex} " << err_suffix)
         end 
      end
   end

   def delete_edge(from_vertex, to_vertex)
      begin
         self[from_vertex].out_edges.delete(to_vertex)
         self[to_vertex].in_edges.delete(from_vertex)
      rescue NoMethodError => e
         err_suffix = "in delete_edge(#{from_vertex}, #{to_vertex})."
         if self[from_vertex].nil?
            puts("No vertex with id #{from_vertex} " << err_suffix)
         else
            puts("No vertex with id #{to_vertex} " << err_suffix)
         end 
      end
   end

   
end
   
