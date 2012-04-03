require 'rspec'
require 'optimizations/memory_allocator/local_table'

describe MemoryAllocator::LocalTable do
  before do
    @table = MemoryAllocator::LocalTable.new
    @table.cclass = :my_class
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

end
