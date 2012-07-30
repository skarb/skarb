#!/usr/bin/ruby

require 'graphviz'
require 'translator'
require 'parser'
require 'optimizations/connection_graph_builder'
require 'optimizations/connection_graph_builder/connection_graph'

unless ARGV.count == 3
   puts "Usage: #{$0} code_file function output_file"
   exit
end

stdlib = File.open('../src/compiler/stdlib.rb').read

translator = Translator.new
options = { :stack_alloc => true, :object_reuse => true, :math_inline => true }
graph_builder = ConnectionGraphBuilder.new(translator, options)

translator.translate(Parser.parse(stdlib + File.open(ARGV[0]).read))

fun = ARGV[1].to_sym

unless graph_builder.local_table.include? fun
   puts "No function named #{fun}. Please choose from the following:"
   p graph_builder.local_table.keys
   exit
end

l = graph_builder.local_table[ARGV[1].to_sym][:last_block][:vars]
g = GraphViz.new( :G, :type => :digraph )

vertices = {}
l.each_key do |key|
   color = case l[key].escape_state
           when :no_escape then "green"
           when :arg_escape then "blue"
           when :global_escape then "red"
           else "white"
           end
   shape = (l[key].is_a? ConnectionGraph::ObjectNode) ? "box" : "ellipse"

   vertices[key] = g.add_nodes(key.to_s, :style => "filled", :shape => shape,
                               :color => color)
end

l.each do |from, from_node|
   from_node.out_edges.each { |to| g.add_edges(vertices[from], vertices[to]) }
end

g.output( :ps2 => ARGV[2] )




