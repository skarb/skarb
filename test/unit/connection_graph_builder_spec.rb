require 'rspec'
require 'set'
require 'translator'
require 'parser'
require 'optimizations/connection_graph_builder'
require 'optimizations/math_inliner'

describe ConnectionGraphBuilder do
  before do
    @translator = Translator.new
    options = { :object_reuse => true, :stack_alloc => true,
       :stack_alloc_no_loops => true }
    @graph_builder = ConnectionGraphBuilder.new(@translator, options)
    @stdlib_declarations = File.open('/home/julek/projects/mgr/src/compiler/stdlib.rb').read
  end

  it 'should store node value of any sexp' do
    @translator.translate(Parser.parse("1"))
    @graph_builder.local_table.last_graph[:"'o1"].should_not be_nil
  end
 
  it 'should store object node allocation sexp' do
    @translator.translate(Parser.parse("1"))
    constructor_sexp = @graph_builder.local_table.last_graph[:"'o1"].constructor_sexp
    alloc_sexp = constructor_sexp.alloc
    type_set_sexp = constructor_sexp.type_set
    alloc_sexp.should == s(:asgn, s(:var, :_var2), s(:call, :xmalloc, s(:args, s(:call, :sizeof, s(:args, s(:lit, :Fixnum))))))
    type_set_sexp.should == s(:call, :set_type, s(:args, s(:var, :_var2), s(:var, :Fixnum)))
  end

  it 'should model array literal' do
    @translator.translate(Parser.parse("[1,2,3]"))
    arr = @graph_builder.local_table.last_graph[:"'o4"]
    arr.constructor_sexp.alloc.should == s(:asgn, s(:var, :_var2), s(:call, :xmalloc, s(:args, s(:call, :sizeof,
                                                       s(:args, s(:lit, :Array))))))
    arr.out_edges.should == Set[:"'o4_[]"]
    elems = @graph_builder.local_table.last_graph[:"'o4_[]"]
    elems.out_edges.should == Set[:"'o1", :"'o2", :"'o3"]
  end

  it 'should model hash literal' do
    @translator.translate(Parser.parse("{1 => 1, 2 => 2, 3 => 3}"))
    hash = @graph_builder.local_table.last_graph[:"'o7"]
    hash.constructor_sexp.alloc.should == s(:asgn, s(:var, :_var2), s(:call, :xmalloc, s(:args, s(:call, :sizeof,
                                                       s(:args, s(:lit, :Hash))))))
    hash.out_edges.should == Set[:"'o7_[]"]
    elems = @graph_builder.local_table.last_graph[:"'o7_[]"]
    elems.out_edges.should == Set[:"'o1", :"'o2", :"'o3", :"'o4", :"'o5", :"'o6"]
  end

  it 'should model if statement value' do
    @translator.translate(Parser.parse("a = (1 if 2)"))
    graph = @graph_builder.local_table.last_graph
    graph[:a].out_edges.should == Set[:"'c1"]
    graph[:"'c1"].out_edges.should == Set[:"'o2"]
  end

  it 'should model if-else statement value' do
    @translator.translate(Parser.parse("a = 1 ? 2 : 3"))
    graph = @graph_builder.local_table.last_graph
    graph[:a].out_edges.should == Set[:"'c1"]
    graph[:"'c1"].out_edges.should == Set[:"'o2", :"'o3"]
  end

  it 'should model case statement value' do
    @translator.translate(Parser.parse(@stdlib_declarations + "a = case 1
                                       when 1,3 then 1
                                       when 2 then 1
                                       else 1
                                       end"))
    graph = @graph_builder.local_table.last_graph
    graph[:a].out_edges.should == Set[:"'c2"]
    graph[:"'c2"].out_edges.should == Set[:"'o3", :"'o6", :"'o7"]
  end

  it 'should build connection graph during code translation' do
     @translator.translate(Parser.parse("p = Object.new; q = p"))
     @graph_builder.local_table.last_graph[:q].out_edges.should == Set[:p]
     @graph_builder.local_table.last_graph[:p].out_edges.should == Set[:"'o1"]
  end
  
  it 'should change context with function change' do
     @translator.translate(Parser.parse("def foo; p = Object.new; end;
                                         def bar; p = Object.new; end"))
     l_table = @graph_builder.local_table
     l_table[:M_Object_foo][:last_block][:vars][:p].out_edges.should == Set[:"'o1"]
     l_table[:M_Object_bar][:last_block][:vars][:p].out_edges.should == Set[:"'o2"]
  end

  it 'should merge connection graphs from different blocks' do
     @translator.translate(Parser.parse("p = Object.new; q = Object.new;
                                        if true; q = p; p = Object.new; end"))
     @graph_builder.local_table.last_graph[:q].out_edges.should == Set[:"'o1", :"'o2"]
     @graph_builder.local_table.last_graph[:p].out_edges.should == Set[:"'o1", :"'o3"]
  end

  it 'should merge connection graphs from different blocks (case 2)' do
     @translator.translate(Parser.parse("p = Object.new; q = Object.new;
                                        if true; p = Object.new; q = p; end"))
     @graph_builder.local_table.last_graph[:q].out_edges.should == Set[:"'o2", :"'o3"]
     @graph_builder.local_table.last_graph[:p].out_edges.should == Set[:"'o1", :"'o3"]
  end

  it 'should accept global and instance variables' do
     @translator.translate(Parser.parse("p = @@a; @b = p"))
     @graph_builder.local_table.last_graph[:p].out_edges.should == Set[:@@a]
     @graph_builder.local_table.last_graph[:self].out_edges.should == Set[:'self_@b']
     @graph_builder.local_table.last_graph[:'self_@b'].out_edges.should == Set[:p]
  end

  it 'should accept literals and strings' do
     @translator.translate(Parser.parse("p = 1; b = p; p = \"str\""))
     @graph_builder.local_table.last_graph[:p].out_edges.should == Set[:"'o2"]
     @graph_builder.local_table.last_graph[:b].out_edges.should == Set[:"'o1"]
  end

  it 'should link return node with all returned values' do
     @translator.translate(Parser.parse("def foo; return 1; if true; return 2; end;
                                        return 3; end"))
     l_table = @graph_builder.local_table
     l_table[:M_Object_foo][:last_block][:vars][:return].out_edges.should ==
        Set[:"'o1", :"'o2", :"'o3"]
  end

  it 'should model abstract parameters and parameters variables at function entry' do
     @translator.translate(Parser.parse("def foo(p1, p2, p3); end"))
     f_table = @graph_builder.local_table[:M_Object_foo___]
     vars = f_table[:last_block][:vars]
     vars[:p1].out_edges.should == Set[:"'p1"]
     vars[:p2].out_edges.should == Set[:"'p2"]
     vars[:p3].out_edges.should == Set[:"'p3"]
     vars[:"'p1"].escape_state.should == :arg_escape
     vars[:"'p2"].escape_state.should == :arg_escape
     vars[:"'p3"].escape_state.should == :arg_escape
     f_table.formal_params.should == [:self, :"'p1", :"'p2", :"'p3"]
  end

  it 'should model self reference correctly' do
     @translator.translate(Parser.parse("a = self"))
     @graph_builder.local_table.last_graph[:a].out_edges.should == Set[:self]
  end

  it 'should model instance variable assignment as edge from self object' do
     @translator.translate(Parser.parse("@a = 1"))
     @graph_builder.local_table.last_graph[:self].out_edges.should == Set[:'self_@a']
     @graph_builder.local_table.last_graph[:'self_@a'].out_edges.should == Set[:"'o1"]
  end

  it 'should correctly merge blocks with instance variables' do
     @translator.translate(Parser.parse("@a = 1; if 1; @a = 2; @b = 3; end"))
     @graph_builder.local_table.last_graph[:self].out_edges.should == Set[:'self_@a',
        :'self_@b']
     @graph_builder.local_table.last_graph[:'self_@a'].out_edges.should == Set[:"'o1", :"'o3"]
     @graph_builder.local_table.last_graph[:'self_@b'].out_edges.should == Set[:"'o4"]
  end

  it 'should update escape state of all nodes at function exit' do
     @translator.translate(Parser.parse("def foo; @@a = 1; @a = 2; a=3; b = 4; return a; end"))
     f_table = @graph_builder.local_table[:M_Object_foo]
     vars = f_table[:last_block][:vars]
     vars[:@@a].escape_state.should == :global_escape
     vars[:"'o1"].escape_state.should == :global_escape
     vars[:'self_@a'].escape_state.should == :arg_escape
     vars[:"'o2"].escape_state.should == :arg_escape
     vars[:a].escape_state.should == :arg_escape
     vars[:"'o3"].escape_state.should == :arg_escape
     vars[:b].escape_state.should == :no_escape
     vars[:"'o4"].escape_state.should == :no_escape
  end 

  it 'should update connection graph basing on information from called functions' do
     @translator.translate(Parser.parse("class A; def p=(v); @p = v; end; end;
                                         a = A.new; a.p=1"))
     main_graph = @graph_builder.local_table[:_main][:last_block][:vars]
     main_graph[:"'o1"].out_edges.should == Set[:"'o1_@p"]
     main_graph[:"'o1_@p"].out_edges.should == Set[:"'o2"]
  end

  it 'should record object returned from function' do
     @translator.translate(Parser.parse("def foo; return 1; end; a = foo"))
     main_graph = @graph_builder.local_table[:_main][:last_block][:vars]
     main_graph[:a].out_edges.should == Set[:"'f1"]
     main_graph[:"'f1"].out_edges.should == Set[:"'om1"]
  end

  it 'should correctly update nested calls' do
     @translator.translate(Parser.parse("class A; def p=(v); @p = v; end;
                                         def a; return self; end; end;
                                         a = A.new; a.a.p=1"))
     main_graph = @graph_builder.local_table[:_main][:last_block][:vars]
     main_graph[:"'o1"].out_edges.should == Set[:"'o1_@p"]
     main_graph[:"'o1_@p"].out_edges.should == Set[:"'o2"]
  end

  it 'should model unknown functions' do
     @translator.translate(Parser.parse("class A; def a(v); 1; end; end;
                                         if 1; a=A.new; else; a=3 end;
                                         b = 4; a.a(b)"))
     main_graph = @graph_builder.local_table[:_main][:last_block][:vars]
     main_graph[:b].out_edges.should == Set[:"'o4"]
     main_graph[:"'o4"].escape_state.should == :global_escape
     main_graph[:"'f1"].out_edges.should == Set[:"'om1"]
     main_graph[:"'om1"].escape_state.should == :global_escape
  end

  it 'should recognize value returned by block' do
     @translator.translate(Parser.parse("a = begin; a = 1; 2; end"))
     main_graph = @graph_builder.local_table[:_main][:last_block][:vars]
     main_graph[:a].out_edges.should == Set[:"'o2"]
  end

  it 'should model value returned implicitely' do
     @translator.translate(Parser.parse("def foo(p); a = 2; a = p; end;
                                         foo(1)"))
     main_graph = @graph_builder.local_table[:_main][:last_block][:vars]
     main_graph[:"'f1"].out_edges.should == Set[:"'o1"]
  end

  it 'should update escape state of objects passed as function arguments' do
     @translator.translate(Parser.parse("def foo(a); @@a = a; end; foo(1)")) 
     main_graph = @graph_builder.local_table[:_main][:last_block][:vars]
     main_graph[:"'o1"].escape_state.should == :global_escape
  end

  it 'should assume that all ivars point to something' do
     @translator.translate(Parser.parse("def foo; @a; end; foo")) 
     main_graph = @graph_builder.local_table[:_main][:last_block][:vars]
     main_graph[:"'f1"].out_edges.should == Set[:"'ph3"]
  end

  it 'should map object from one function to a set of objects from another' do
     cg = ConnectionGraph
     l_table = @graph_builder.local_table
     
     l_table.cfunction = :foo
     l_table.assure_existence(:self, cg::PhantomNode)
     l_table.assure_existence(:"self_@a", cg::FieldNode)
     l_table.assure_existence(:"self_@b", cg::FieldNode)
     l_table.assure_existence(:"'ph_1", cg::PhantomField)
     l_table.assure_existence(:"'ph_2", cg::PhantomField)
     l_table.get_var_node(:"'ph_1").parent_field = :"self_@a"
     l_table.get_var_node(:"'ph_2").parent_field = :"self_@b"
     l_table.last_graph.add_edge(:self, :"self_@a")
     l_table.last_graph.add_edge(:self, :"self_@b")
     l_table.last_graph.add_edge(:"self_@a", :"'ph_1")
     l_table.last_graph.add_edge(:"self_@b", :"'ph_2")

     l_table.cfunction = :_main
     l_table.assure_existence(:"'o1", cg::ObjectNode)
     l_table.assure_existence(:"'o1_@a", cg::FieldNode)
     l_table.assure_existence(:"'o2", cg::ObjectNode)
     l_table.assure_existence(:"'o3", cg::ObjectNode)
     l_table.last_graph.add_edge(:"'o1", :"'o1_@a")
     l_table.last_graph.add_edge(:"'o1_@a", :"'o2")
     l_table.last_graph.add_edge(:"'o1_@a", :"'o3")

     mapping = { :self => :"'o1" }

     @graph_builder.maps_to_set(:"'ph_1", :foo, mapping).should == [:"'o3", :"'o2" ]
     @graph_builder.maps_to_set(:"'ph_2", :foo, mapping).should == [:"'ph1"]
     l_table.get_var_node(:"'o1").out_edges.should == Set[:"'o1_@a", :"'o1_@b"]
     l_table.get_var_node(:"'o1_@b").out_edges.should == Set[:"'ph1"]
     l_table.get_var_node(:"'ph1").parent_field.should == :"'o1_@b"
  end

  it 'should update escape state of fields of objects passed as arguments' do
     @translator.translate(Parser.parse("class A; def a=(v); @a=v; end;
                                         def a; @a; end; end;
                                         def foo(a); @@g = a.a; end;
                                         a = A.new; a.a = 1; foo(a)")) 
     main_graph = @graph_builder.local_table[:_main][:last_block][:vars]
     main_graph[:"'o1_@a"].out_edges.should == Set[:"'o2"]
     main_graph[:"'o2"].escape_state.should == :global_escape
  end

  it 'should drop outdated field values after function return' do
     @translator.translate(Parser.parse("def foo; @a = 2; end; @a = 1; foo"))
     main_graph = @graph_builder.local_table[:_main][:last_block][:vars]
     main_graph[:"self_@a"].out_edges.should == Set[:"'om1"]
  end

  it 'should assume that every class var has value and model assignment to it' do
     @translator.translate(Parser.parse("def foo; @@a = @@b; end"))
     foo_graph = @graph_builder.local_table[:M_Object_foo][:last_block][:vars]
     foo_graph[:"@@b"].out_edges.should == Set[:"'ph1"]
     foo_graph[:"@@a"].out_edges.should == Set[:"@@b"]
     foo_graph[:return].out_edges.should == Set[:"@@a"]
  end
 
  it 'should assume adequate escape state of phantom fields' do
     @translator.translate(Parser.parse("def foo; a = @a; @a = 1; b = @@b;
                                         @@b = 1; end")) 
     foo_graph = @graph_builder.local_table[:M_Object_foo][:last_block][:vars]
     foo_graph[:a].out_edges.should == Set[:"'ph1"]
     foo_graph[:"self_@a"].out_edges.should == Set[:"'o1"]
     foo_graph[:"'ph1"].escape_state.should == :arg_escape
     foo_graph[:b].out_edges.should == Set[:"'ph2"]
     foo_graph[:"'ph2"].escape_state.should == :global_escape
     foo_graph[:"@@b"].out_edges.should == Set[:"'o2"]
  end

  it 'should use supplied connection graphs of stdlib functions' do
     @translator.translate(Parser.parse(@stdlib_declarations + "n = 1; puts(n)"))
     main_graph = @graph_builder.local_table[:_main][:last_block][:vars]
     main_graph[:n].out_edges.should == Set[:"'o1"]
     main_graph[:"'o1"].escape_state.should == :no_escape
  end

  it 'should store the type of created objects' do
     @translator.translate(Parser.parse("def foo; a = 1.2; @a = a; end; foo;"))
     main_graph = @graph_builder.local_table[:_main][:last_block][:vars]
     main_graph[:'self_@a'].out_edges.should == Set[:"'om1"]
     main_graph[:"'om1"].type.should == :Float
  end

  it 'should reuse stack allocated object memory' do
     s = @translator.translate(Parser.parse("def foo; a = 1; a = 2; 3; end; foo;"))
     prg_txt = s.join(" ")
     prg_txt.include?("_var6 call SMALLOC").should be_true
     prg_txt.include?("asgn var _var7 var _var6").should be_true
  end

  it 'should not allocate object created inside loops on the stack' do
     s = @translator.translate(Parser.parse("def foo; a = 1; while 1; b = 1; end; end; foo;"))
     prg_txt = s.join(" ")
     prg_txt.include?("_var12 call xmalloc").should be_true
     prg_txt.include?("_var8 call SMALLOC").should be_true
  end

  it 'should find dead objects' do
     @translator.translate(Parser.parse("a = 1; a = 2; @a = 5.5; @@a = a; if 1; @a = 3; end"))
     l_table = @graph_builder.local_table
     l_table.find_all_objects.should == Set[:self, :"'o1", :"'o2", :"'o3", :"'o4", :"'o5"]
     l_table.find_live_objects.should == Set[:self, :"'o2", :"'o3", :"'o5"]
     l_table.find_dead_objects(:Fixnum).should == [:"'o1", :"'o4"]
  end

  it 'should cope with cyclic references' do
     @translator.translate(Parser.parse(
        <<-eos
class A
   def a=(v)
      @a = v
   end

   def a
      @a
   end
end

def foo
   o = A.new
   o.a = o
end

foo
        eos
     ))
  end
end
