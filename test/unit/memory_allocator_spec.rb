require 'rspec'
require 'set'
require 'translator'
require 'parser'
require 'optimizations/memory_allocator'

describe MemoryAllocator do
  before do
    @translator = Translator.new
    @mem_alloc = MemoryAllocator.new(@translator)
  end

  it 'should build connection graph during code translation' do
     @translator.translate(Parser.parse("p = Object.new; q = p"))
     @mem_alloc.local_table.last_graph[:q].out_edges.should == Set[:p]
     @mem_alloc.local_table.last_graph[:p].out_edges.should == Set[:o1]
  end
  
  it 'should change context with function change' do
     @translator.translate(Parser.parse("def foo; p = Object.new; end;
                                         def bar; p = Object.new; end"))
     l_table = @mem_alloc.local_table
     l_table[l_table.cclass][:foo][:vars][:p].out_edges.should == Set[:o1]
     l_table[l_table.cclass][:bar][:vars][:p].out_edges.should == Set[:o2]
  end

  it 'should merge connection graphs from different blocks' do
     @translator.translate(Parser.parse("p = Object.new; q = Object.new;
                                        if true; q = p; p = Object.new; end"))
     @mem_alloc.local_table.last_graph[:q].out_edges.should == Set[:o1, :o2]
     @mem_alloc.local_table.last_graph[:p].out_edges.should == Set[:o1, :o3]
  end

  it 'should accept global and instance variables' do
     @translator.translate(Parser.parse("p = @@a; @b = p"))
     @mem_alloc.local_table.last_graph[:p].out_edges.should == Set[:@@a]
     @mem_alloc.local_table.last_graph[:@b].out_edges.should == Set[:p]
  end

  it 'should accept literals and strings' do
     @translator.translate(Parser.parse("p = 1; b = p; p = \"str\""))
     @mem_alloc.local_table.last_graph[:p].out_edges.should == Set[:o2]
     @mem_alloc.local_table.last_graph[:b].out_edges.should == Set[:o1]
  end

end
