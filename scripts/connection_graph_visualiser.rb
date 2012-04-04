#!/usr/bin/ruby

require 'graphviz'
require 'translator'
require 'parser'
require 'optimizations/memory_allocator'
require 'optimizations/memory_allocator/connection_graph'

unless ARGV.count == 2
   puts "Usage: #{$0} code_file output_file"
   exit
end


translator = Translator.new
mem_alloc = MemoryAllocator.new(translator)

translator.translate(Parser.parse(File.open(ARGV[0]).read))

l = mem_alloc.local_table.last_graph
g = GraphViz.new( :G, :type => :digraph )

vertices = {}
l.each_key do |key|
   if l[key].is_a? ConnectionGraph::ObjectNode
      vertices[key] = g.add_nodes(key.to_s, :shape => "box")
   else
      vertices[key] = g.add_nodes(key.to_s)
   end
end

l.each do |from, from_node|
   from_node.out_edges.each { |to| g.add_edges(vertices[from], vertices[to]) }
end

g.output( :png => ARGV[1] )




