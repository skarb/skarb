require 'rspec'
require 'emitter'
require 'emitter/errors'
require 'sexp_processor'

describe Array do
  before do
    @array = [1, 2, 3, 4, 5, 6]
  end

  it 'should implement rest function' do
    @array.rest.should == [2, 3, 4, 5, 6]
  end

  it 'should implement middle function' do
    @array.middle.should == [2, 3, 4, 5]
  end
end

describe Emitter do
  before do
    @emitter = Emitter.new
  end

  def emit(sexp)
    @emitter.emit sexp
  end

  it 'should emit include declaration' do
    emit(s(:include, '<stdio.h>')).should == '#include <stdio.h>'
  end

  it 'should emit define declaration' do
    emit(s(:define , 'x (y/z)')).should == '#define x (y/z)'
  end

  it 'should emit goto' do
    emit(s(:goto, :abc)).should == 'goto abc'
  end

  it 'should emit a hello world' do
    hellow_body = s(:block)
    args = s(:abstract_args,
             s(:decl, :int, :argc),
             s(:decl, :'char**', :args))
    hellow_main = s(:defn, :int, :main, args, hellow_body)
    hellow_body.push(s(:call, :printf,
                       s(:actual_args, s(:str, 'Hello world!'))))
    hellow_body.push(s(:return, s(:lit, 0)))
    emit(hellow_main).should ==
      "int main(int argc,char** args){printf(\"Hello world!\");return 0;}"
  end

  it 'should emit variable declaration' do
    emit(s(:decl, :my_type, :a)).should == 'my_type a'
  end

  it 'should emit unsigned modifier' do
    emit(s(:unsigned, s(:decl, :int, :a))).should == 'unsigned int a'
  end

  it 'should emit signed modifier' do
    emit(s(:signed, s(:decl, :int, :a))).should == 'signed int a'
  end

  it 'should emit const modifier' do
    emit(s(:const, s(:decl, :int, :a))).should == 'const int a'
  end

  it 'should emit volatile modifier' do
    emit(s(:volatile, s(:decl, :int, :a))).should == 'volatile int a'
  end

  it 'should emit static modifier' do
    emit(s(:static, s(:decl, :int, :a))).should == 'static int a'
  end

  it 'should emit auto modifier' do
    emit(s(:auto, s(:decl, :int, :a))).should == 'auto int a'
  end

  it 'should emit extern modifier' do
    emit(s(:extern, s(:decl, :int, :a))).should == 'extern int a'
  end

  it 'should emit register modifier' do
    emit(s(:register, s(:decl, :int, :a))).should == 'register int a'
  end

  it 'should emit a block with two statements' do
    emit(s(:block,
           s(:call, :fun, s(:abstract_args, nil)),
           s(:call, :asdf, s(:abstract_args, s(:var, :x)))),
        ).should == "{fun();asdf(x);}"
  end

  it 'should emit if clause' do
    emit(s(:if, s(:lit, 1),
           s(:block, s(:return, s(:lit, 1))),
           s(:block, s(:return, s(:lit, 0))))
        ).should == "if(1){return 1;}else{return 0;}"
  end

  it 'should emit assignment' do
    emit(s(:asgn, s(:var, :a), s(:lit, 2))).should == 'a=2'
  end

  it 'should emit special assignment' do
    %w{|| && + - / ^ %}.each do |op|
      emit(s(:aasgn, op + '=', s(:var, :x), s(:var, :y))).should == "x#{op}=y"
    end
  end

  it 'should emit for clause, assignment, right unary operator, lvar' do
    emit(s(:for,
           s(:asgn, s(:var, :a), s(:lit, 2)),
           s(:lit, 1),
           s(:r_unary_oper, :'++', s(:var, :a)),
           s(:block, s(:return, s(:lit, 1))))
        ).should == "for(a=2;1;a++){return 1;}"
  end

  it 'should emit a while loop' do
    emit(s(:while, s(:var, :x), s(:block, s(:r_unary_oper, :'--', s(:var, :x))))
        ).should == "while(x){x--;}"
  end

  it 'should emit a do while loop' do
    emit(s(:do, s(:block, s(:call, :x, s(:arglist, nil))), s(:var, :y))
        ).should == "do{x();}while(y);"
  end

  it 'should emit binary operator' do
    emit(s(:binary_oper, :>, s(:lit, 1), s(:lit, 3))).should == '1>3'
  end

  it 'should emit left unary operator' do
    emit(s(:l_unary_oper, :-, s(:lit, 1))).should == '-1'
  end

  it 'should emit switch' do
    emit(s(:switch, s(:lit, 1), s(:block))).should == "switch(1){}"
  end

  it 'should emit default' do
    emit(s(:default)).should == 'default:'
  end

  it 'should emit break' do
    emit(s(:break)).should == 'break'
  end

  it 'should emit return' do
    emit(s(:return)).should == 'return'
  end

  it 'should emit continue' do
    emit(s(:continue)).should == 'continue'
  end

  it 'should emit case' do
    emit(s(:case, s(:lit, 1))).should == 'case 1:'
  end

  it 'should emit short if' do
    emit(s(:short_if, s(:lit, 1), s(:lit, 2), s(:lit, 3))).should == '1?2:3'
  end

  it 'should emit typedef' do
    emit(s(:typedef, :int, :my_int)).should == 'typedef int my_int'
  end

  it 'should emit typedef with struct' do
    emit(s(:typedef, s(:struct, nil, s(:block, s(:decl, :int, :a))), :my_struct)
        ).should == "typedef struct  {int a;} my_struct"
  end

  it 'should emit union' do
    emit(s(:union, :my_union, s(:block, s(:decl, :int, :a)))
        ).should == "union my_union {int a;}"
  end

  it 'should emit prototype' do
    emit(s(:prototype, :int, :foo, s(:abstract_args, s(:decl, :int, :a)))
        ).should == 'int foo(int a)'
  end

  it 'should emit goto label' do
    emit(s(:label, :abc)).should == 'abc:'
  end

  it 'should not accept a sexp with an unexpected type' do
    expect do
      emit s(:no_such_sexp)
    end .to raise_error Emitter::Errors::UnexpectedSexpError
  end
end
