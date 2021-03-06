# Copyright (c) 2010-2012 Jan Stępień, Julian Zubek
#
# This file is a part of Skarb -- a Ruby to C compiler.
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

require 'set'

# Class representing connection graph. It is a hash containing ids of the
# vertices. Under each key a node object is stored -- it contains outgoing
# and incoming edges sets as well as aditional properties.
#
# Convention: vertex means vertex id, node means associated node object.
# TODO: Change object hierarchy
class ConnectionGraph < Hash

   # Generic node in connection graph. 
   class Node
      # escape_state -- if the node escapes from its local function.
      # out_edges, in_edges -- connected nodes.
      # existence_state -- if the node exists in current block regerdless of
      #                    execution path or if its existence is conditional.
      attr_accessor :escape_state, :out_edges, :in_edges, :existence_state
      
      def initialize(esc_state = :no_escape)
         @out_edges = Set.new
         @in_edges = Set.new
         @escape_state = esc_state
         @existence_state = :certain
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
      attr_accessor :constructor_sexp, :type, :potential_precursors
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

   # Node representing currently evaluated expression.
   class ExprNode < Node
   end

   # Adds edge between two vertices, updating in_edges and out_edges sets.
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

   # Deletes edge between two vertices, updating in_edges and out_edges sets.
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

   # Deletes vertex deleting all its edges before.
   def delete_vertex(vertex)
      out_e = self[vertex].out_edges.to_a
      out_e.each { |e| delete_edge(vertex, e) }
      in_e = self[vertex].in_edges.to_a
      in_e.each { |e| delete_edge(e, vertex) }
      self.delete(vertex)
   end
   
end
   
