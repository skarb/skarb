require 'rspec'
require 'emitter'
require 'sexp_processor'

describe Array do
  before do
    @array = [1, 2, 3, 4, 5, 6]
  end

  it 'should implement rest function' do
    @array.rest.should ==
      [2, 3, 4, 5, 6]    
  end

  it 'should implement middle function' do
    @array.middle.should ==
      [2, 3, 4, 5]    
  end
  
end

describe Emitter do
  before do
    @emitter = Emitter.new
    @hellow_body = Sexp.new(:block)
    @hellow_main = Sexp.new(:defn, :int, :main, Sexp.new(:abstract_args, Sexp.new(:decl, :int, :argc),
	Sexp.new(:decl, :'char**', :args)), @hellow_body)
    @hellow_body.push(Sexp.new(:call, :printf, Sexp.new(:actual_args, Sexp.new(:str, "Hello world!"))))
    @hellow_body.push(Sexp.new(:return, Sexp.new(:lit, 0)))
  end

  it 'should emit include declaration' do
    @emitter.emit(Sexp.new(:include, "<stdio.h>")).should ==
      "#include <stdio.h>"
  end

  it 'should emit define declaration' do
    @emitter.emit(Sexp.new(:define , "x (y/z)")).should ==
      "#define x (y/z)"
  end

  it 'should emit goto' do
    @emitter.emit(Sexp.new(:goto, :abc)).should ==
      "goto abc"
  end

  it 'should emit a hello world' do
    @emitter.emit(@hellow_main).should ==
      "int main(int argc, char** args)\n{\nprintf(\"Hello world!\");\nreturn 0;\n}\n"
  end

  it 'should emit variable declaration' do
    @emitter.emit(Sexp.new(:decl, :my_type, :a)).should ==
      "my_type a"
  end

  it 'should emit unsigned modifier' do
    @emitter.emit(Sexp.new(:unsigned, Sexp.new(:decl, :int, :a))).should ==
     "unsigned int a"
  end 

  it 'should emit signed modifier' do
    @emitter.emit(Sexp.new(:signed, Sexp.new(:decl, :int, :a))).should ==
     "signed int a"
  end 

  it 'should emit const modifier' do
    @emitter.emit(Sexp.new(:const, Sexp.new(:decl, :int, :a))).should ==
     "const int a"
  end 

  it 'should emit volatile modifier' do
    @emitter.emit(Sexp.new(:volatile, Sexp.new(:decl, :int, :a))).should ==
     "volatile int a"
  end 

  it 'should emit static modifier' do
    @emitter.emit(Sexp.new(:static, Sexp.new(:decl, :int, :a))).should ==
     "static int a"
  end 

  it 'should emit auto modifier' do
    @emitter.emit(Sexp.new(:auto, Sexp.new(:decl, :int, :a))).should ==
     "auto int a"
  end 

  it 'should emit extern modifier' do
    @emitter.emit(Sexp.new(:extern, Sexp.new(:decl, :int, :a))).should ==
     "extern int a"
  end 

  it 'should emit register modifier' do
    @emitter.emit(Sexp.new(:register, Sexp.new(:decl, :int, :a))).should ==
     "register int a"
  end 

  it 'should emit if clause' do
    @emitter.emit(Sexp.new(:if, Sexp.new(:lit, 1),
                           Sexp.new(:subblock,
                           Sexp.new(:return, Sexp.new(:lit, 1))),
                           Sexp.new(:subblock,
                           Sexp.new(:return, Sexp.new(:lit, 0))))).should ==
     "if (1)\nreturn 1;\nelse\nreturn 0;\n"
  end 

  it 'should emit assignment' do
    @emitter.emit(Sexp.new(:asgn, Sexp.new(:var, :a), Sexp.new(:lit, 2))).should ==
      "a = 2"
  end

  it 'should emit special assignment' do
    %w{|| && + - / ^ %}.each do |op|
      @emitter.emit(Sexp.new(:aasgn, op + '=',
                             Sexp.new(:var, :x),
                             Sexp.new(:var, :y))).should == "x #{op}= y"
    end
  end

  it 'should emit for clause, assignment, right unary operator, lvar' do
    @emitter.emit(Sexp.new(:for, Sexp.new(:asgn, Sexp.new(:var, :a),
                                          Sexp.new(:lit, 2)),
                           Sexp.new(:lit, 1), Sexp.new(:r_unary_oper, :'++',
                                                       Sexp.new(:var, :a)),
                           Sexp.new(:subblock, Sexp.new(:return,
                                                     Sexp.new(:lit, 1))))).should ==
     "for (a = 2; 1; a++)\nreturn 1;\n"
  end 

  it 'should emit a while loop' do
    @emitter.emit(Sexp.new(:while, Sexp.new(:var, :x),
                           Sexp.new(:subblock,
                           Sexp.new(:l_unary_oper, :'--', :x)))) ==
                           "while (x)\nx--;\n"
  end

  it 'should emit a do while loop' do
    @emitter.emit(Sexp.new(:do, Sexp.new(:call, :x),
                           Sexp.new(:var, :y))) ==
                           "do x(); while (y);\n"
  end

  it 'should emit binary operator' do
    @emitter.emit(Sexp.new(:binary_oper, :>, Sexp.new(:lit, 1),
                           Sexp.new(:lit, 1))).should ==
     "1 > 1"
  end

  it 'should emit left unary operator' do
    @emitter.emit(Sexp.new(:l_unary_oper, :-, Sexp.new(:lit, 1))).should ==
     "-1"
  end

  it 'should emit switch' do
    @emitter.emit(Sexp.new(:switch, Sexp.new(:lit, 1),
                          Sexp.new(:block))).should ==
      "switch (1)\n{\n}\n"
  end

  it 'should emit default' do
    @emitter.emit(Sexp.new(:default)).should ==
      "default: "
  end

  it 'should emit break' do
    @emitter.emit(Sexp.new(:break)).should ==
      "break"
  end
  
  it 'should emit return' do
    @emitter.emit(Sexp.new(:return)).should ==
      "return"
  end

  it 'should emit continue' do
    @emitter.emit(Sexp.new(:continue)).should ==
      "continue"
  end

  it 'should emit case' do
    @emitter.emit(Sexp.new(:case, Sexp.new(:lit, 1))).should ==
      "case 1: "
  end

  it 'should emit short if' do
    @emitter.emit(Sexp.new(:short_if, Sexp.new(:lit, 1),
                           Sexp.new(:lit, 1), Sexp.new(:lit, 1))).should ==
     "1 ? 1 : 1"
  end

  it 'should emit typedef' do
    @emitter.emit(Sexp.new(:typedef, :int, :my_int)).should ==
      "typedef int my_int"
  end

  it 'should emit typedef with struct' do
    @emitter.emit(Sexp.new(:typedef,
                           Sexp.new(:struct, nil,
                                     Sexp.new(:block,
                                              Sexp.new(:decl, :int, :a))),
                           :my_struct)).should ==
      "typedef struct  {\nint a;\n}\n my_struct"
  end

  it 'should emit union' do
    @emitter.emit(Sexp.new(:union, :my_union,
                           Sexp.new(:block, Sexp.new(:decl, :int, :a)))).should ==
      "union my_union {\nint a;\n}\n"
  end

  it 'should emit prototype' do
    @emitter.emit(Sexp.new(:prototype, :int, :foo,
                           Sexp.new(:abstract_args, Sexp.new(:decl, :int, :a)))).should ==
      "int foo (int a)"
  end

  it 'should emit goto label' do
    @emitter.emit(Sexp.new(:label, :abc)).should ==
      "abc: "
  end

end
