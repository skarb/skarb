require 'rspec'
require 'set'
require 'optimizations/connection_graph_builder/local_table'

describe ConnectionGraphBuilder::LocalTable do
  before do
    @table = ConnectionGraphBuilder::LocalTable.new
    @table.cfunction = :my_function
  end

  it 'should organize data in blocks' do
    @table.cfunction = :t1_function
    @table.add_node(:a, ConnectionGraph::Node.new)
    @table.open_block
    @table.add_node(:b, ConnectionGraph::Node.new)

    @table.get_var_node(:a).should_not be nil
    @table.get_var_node(:b).should_not be nil
    @table.last_block[:vars].has_key?(:a).should be false 
    @table.last_block[:vars].has_key?(:b).should be true
    @table.last_block[:parent][:vars].has_key?(:a).should be true

    @table.copy_var_node(:a)
    @table.last_block[:vars].has_key?(:a).should be true  
  end

  it 'should copy node to last block' do
    @table.cfunction = :t3_function
    @table.add_node(:a, ConnectionGraph::Node.new)
    @table.add_node(:b, ConnectionGraph::Node.new)
    @table.last_block[:vars].add_edge(:a, :b)

    @table.last_block[:vars][:a].out_edges.include?(:b).should be true
    @table.last_block[:vars][:b].in_edges.include?(:a).should be true

    @table.open_block
    @table.copy_var_node(:a)

    @table.last_block[:vars][:a].out_edges.include?(:b).should be true
  end

  it 'should correctly by pass a node' do
    @table.cfunction = :t3_function
    @table.add_node(:a2, ConnectionGraph::Node.new)
    @table.add_node(:a1, ConnectionGraph::Node.new)
    @table.add_node(:b, ConnectionGraph::Node.new)
    @table.add_node(:c1, ConnectionGraph::Node.new)
    @table.add_node(:c2, ConnectionGraph::Node.new)
    @table.last_block[:vars].add_edge(:a1, :b)
    @table.last_block[:vars].add_edge(:a2, :b)
    @table.last_block[:vars].add_edge(:b, :c1)
    @table.last_block[:vars].add_edge(:b, :c2)
    
    @table.open_block
    @table.by_pass(:b)

    @table.last_block[:vars][:a1].out_edges.include?(:b).should be false
    @table.last_block[:vars][:a1].out_edges.include?(:c1).should be true
    @table.last_block[:vars][:a1].out_edges.include?(:c2).should be true
    @table.last_block[:vars][:a2].out_edges.include?(:b).should be false
    @table.last_block[:vars][:a2].out_edges.include?(:c1).should be true
    @table.last_block[:vars][:a2].out_edges.include?(:c2).should be true
    @table.last_block[:vars][:b].out_edges.include?(:c1).should be false
    @table.last_block[:vars][:b].out_edges.include?(:c2).should be false
  end

  it 'should correctly merge blocks' do
    @table.cfunction = :t3_function
    @table.add_node(:r, ConnectionGraph::Node.new)
    @table.add_node(:p, ConnectionGraph::Node.new)
    @table.add_node(:A, ConnectionGraph::Node.new)
    @table.last_block[:vars].add_edge(:p, :A)
    @table.last_block[:vars].add_edge(:r, :p)
    @table.open_block
    @table.add_node(:B, ConnectionGraph::Node.new)
    @table.by_pass(:p)
    @table.last_block[:vars].add_edge(:p, :B)
    @table.add_node(:q, ConnectionGraph::Node.new)
    @table.last_block[:vars].add_edge(:q, :p)
    @table.close_block

    @table.last_block[:vars][:p].out_edges.should == Set[:A, :B]
    @table.last_block[:vars][:r].out_edges.should == Set[:A]
    @table.last_block[:vars][:q].out_edges.should == Set[:B]
  end

end
