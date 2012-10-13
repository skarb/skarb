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

      mapping = Hash.new { |hash, key| key }

      @local_table.formal_params << :self
      args = graph_sexp.find_node(:args)
      model_params(args)

      new_objs = graph_sexp.find_node(:new_objects)
      model_new_objects(new_objs, mapping) 

      ph_fields = graph_sexp.find_node(:phantom_fields)
      model_phantom_fields(ph_fields, mapping)

      g_esc = graph_sexp.find_node(:global_escape)
      set_esc_states(g_esc, mapping)

      graph_edges = graph_sexp.find_node(:graph_edges)
      model_graph_edges(graph_edges, mapping)

      # Propagate global_escape state (all other objects have arg_escape state).
      if g_esc
         g_esc.rest.each { |esc| @local_table.propagate_escape_state(esc) }
      end

      ret = graph_sexp.find_node(:return)
      model_return(ret, mapping)

      @local_table.cfunction = old_function
   end

   # Model returned object.
   def model_return(ret, mapping)
      if ret
        ret_obj = mapping[ret[1]]
        # If object was previously undeclared, we assume it to be newly created one.
        unless @local_table.last_graph[ret_obj]
           mapping[ret_obj] = @graph_builder.next_key(:os)
           ret_obj = mapping[ret_obj]
           @local_table.abstract_objects << ret_obj
           @local_table.assure_existence(ret_obj, ConnectionGraph::ObjectNode,
                                      :arg_escape)
        end
        @local_table.last_graph.add_edge(:return, ret_obj)
      end
   end

   # Model params.
   def model_params(args)
      if args
         args.rest.each do |arg|
            @local_table.assure_existence(arg, ConnectionGraph::PhantomNode,
                                          :arg_escape)
            @local_table.formal_params << arg
         end
      end
   end

   # Model objects created in the function.
   def model_new_objects(new_objs, mapping)
      if new_objs
         new_objs.rest.each do |new_obj|
            mapping[new_obj] = @graph_builder.next_key(:os)
            @local_table.abstract_objects << mapping[new_obj]
            @local_table.assure_existence(mapping[new_obj],
                                          ConnectionGraph::ObjectNode, :arg_escape)
         end
      end
   end

   # Model phantom field objects referenced in the function.
   def model_phantom_fields(ph_fields, mapping)
      if ph_fields
         ph_fields.rest.each do |ph_obj|
            mapping[ph_obj] = @graph_builder.next_key(:phs)
            @local_table.assure_existence(mapping[ph_obj],
                                          ConnectionGraph::PhantomField, :arg_escape)
         end
      end
   end

   # Set global escape state of selected objects.
   def set_esc_states(g_esc, mapping)
      if g_esc
         g_esc.rest.each do |esc_obj|
            @local_table.last_graph[mapping[esc_obj]].escape_state = :global_escape
         end 
      end
   end

   # Model graph edges. All previously undeclared nodes are treated as fields. 
   def model_graph_edges(graph_edges, mapping)
      if graph_edges
         graph_edges.rest.each do |edge|
            a = mapping[edge[0]]
            b = mapping[edge[1]]
            @local_table.assure_existence(a, ConnectionGraph::FieldNode)
            @local_table.assure_existence(b, ConnectionGraph::FieldNode)
            @local_table.last_graph.add_edge(a, b)
         end 
      end
   end

end
