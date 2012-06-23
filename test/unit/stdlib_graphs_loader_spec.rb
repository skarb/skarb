require 'rspec'
require 'sexp_processor'
require 'set'
require 'translator'
require 'optimizations/connection_graph_builder'
require 'optimizations/connection_graph_builder/local_table'
require 'optimizations/connection_graph_builder/stdlib_graphs_loader'

describe StdlibGraphsLoader do
  before do
    @translator = Translator.new
    @graph_builder = ConnectionGraphBuilder.new(@translator)
    @graph_loader = StdlibGraphsLoader.new(@graph_builder)
    @ltable = @graph_builder.local_table
  end

  it 'create connection graph for function from abstract description' do
    g = s(:function, :foo, s(:args, :"'p1", :"'p2"),
          s(:global_escape, :"'p2"),
          s(:new_objects, :"'o1"),
          s(:graph_edges,
            s(:self, :"self_@a"),
            s(:"self_@a", :"'p1"),
            s(:"'p2", :"'p2_@a"),
            s(:"'p2_@a", :"'p1"),
            s(:return, :"'o1")))
    @graph_loader.load(g)
    cg = @ltable[:foo].last_block[:vars]
    cg[:self].out_edges = Set[:"self_@a"]
    cg[:"self_@a"].out_edges = Set[:"'p1"]
    cg[:"'p2"].out_edges = Set[:"'p2_@a"]
    cg[:"'p2_@a"].out_edges = Set[:"'p1"]
    cg[:return].out_edges = Set[:"'o1"]
    cg[:"'p2"].escape_state = :global_escape
    cg[:"'p1"].escape_state = :global_escape
  end
  
end
