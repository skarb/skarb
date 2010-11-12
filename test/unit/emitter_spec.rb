require 'rspec'
require 'emitter'
require 'sexp_processor'

describe Emitter do
  before do
    @emitter = Emitter.new
    @hellow_body = Sexp.new(:block)
    @hellow_main = Sexp.new(:defn, :int, :main, Sexp.new(:abstract_args, Sexp.new(:int, :argc),
	Sexp.new(:'char**', :args)), Sexp.new(:scope, @hellow_body))
    @hellow_body.push(Sexp.new(:call, :printf, Sexp.new(:actual_args, Sexp.new(:str, "Hello world!"))))
    @hellow_body.push(Sexp.new(:return, Sexp.new(:lit, 0)))
  end

  it 'should emit a hello world' do
    @emitter.emit(@hellow_main).should ==
      "int main(int argc, char** args)\n{\nprintf(\"Hello world!\");\nreturn 0;\n}\n"
  end

  it 'should emit int variable declaration' do
    @emitter.emit(Sexp.new(:int, :a)).should ==
      "int a"
  end

=begin
  it 'should emit char variable declaration' do
    @emitter.emit(Sexp.new(:char, :a)).should ==
      "char a"
  end

  it 'should emit short variable declaration' do
    @emitter.emit(Sexp.new(:short, :a)).should ==
      "short a"
  end

  it 'should emit long variable declaration' do
    @emitter.emit(Sexp.new(:long, :a)).should ==
      "long a"
  end

  it 'should emit float variable declaration' do
    @emitter.emit(Sexp.new(:float, :a)).should ==
      "float a"
  end

  it 'should emit double variable declaration' do
    @emitter.emit(Sexp.new(:double, :a)).should ==
      "double a"
  end

  it 'should emit ctype variable declaration' do
    @emitter.emit(Sexp.new(:ctype, :my_type, :a)).should ==
      "my_type a"
  end

  it 'should emit unsigned modifier' do
    @emitter.emit(Sexp.new(:unsigned, Sexp.new(:int, a))).should ==
     "unsigned int a"
  end 

  it 'should emit signed modifier' do
    @emitter.emit(Sexp.new(:signed, Sexp.new(:int, a))).should ==
     "signed int a"
  end 

  it 'should emit const modifier' do
    @emitter.emit(Sexp.new(:const, Sexp.new(:int, a))).should ==
     "const int a"
  end 

  it 'should emit volatile modifier' do
    @emitter.emit(Sexp.new(:volatile, Sexp.new(:int, a))).should ==
     "volatile int a"
  end 

  it 'should emit static modifier' do
    @emitter.emit(Sexp.new(:static, Sexp.new(:int, a))).should ==
     "static int a"
  end 

  it 'should emit auto modifier' do
    @emitter.emit(Sexp.new(:auto, Sexp.new(:int, a))).should ==
     "auto int a"
  end 

  it 'should emit extern modifier' do
    @emitter.emit(Sexp.new(:extern, Sexp.new(:int, a))).should ==
     "extern int a"
  end 

  it 'should emit register modifier' do
    @emitter.emit(Sexp.new(:register, Sexp.new(:int, a))).should ==
     "register int a"
  end 

  it 'should emit if clause' do
    @emitter.emit(Sexp.new(:if, Sexp.new(:lit, 1),
                           Sexp.new(:return, Sexp.new(:lit, 1)),
                           Sexp.new(:return, Sexp.new(:lit, 0)))).should ==
     "if(1)\n{\nreturn 1;\n} else\n{\nreturn 0;}"
  end 

  it 'should emit for clause, assignment, right unary operator, lvar' do
    @emitter.emit(Sexp.new(:for, Sexp.new(:asgn, Sexp.new(:lvar, :a),
                                          Sexp.new(:lit, 2)),
                           Sexp.new(:lit, 1), Sexp.new(:r_unary_oper, :'++',
                                                       Sexp.new(:lvar, :a)),
                           Sexp.new(:block, Sexp.new(:return,
                                                     Sexp.new(:lit, 1))))).should ==
     "for(a = 2; 1; a++)\n{\nreturn 1;\n}"
  end 

  it 'should emit binary operator' do
    @emitter.emit(Sexp.new(:binary_oper, :>, Sexp.new(:lit, 1),
                           Sexp.new(:lit, 1))).should ==
     "1 > 1"
  end

  it 'should emit left unary operator' do
    @emitter.emit(Sexp.new(:l_unary_oper, :>, :-, Sexp.new(:lit, 1))).should ==
     "-1"
  end

  it 'should emit switch' do
    @emitter.emit(Sexp.new(:switch, Sexp.new(:lit, 1),
                          Sexp.new(:block))).should ==
      "switch(1)\n{\n}"
  end

  it 'should emit default' do
    @emitter.emit(Sexp.new(:default)).should ==
      "default:"
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
      "case 1:"
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
                           Sexp.new(:struct, :_my_struct,
                                     Sexp.new(:block,
                                              Sexp.new(:int, :a))),
                           :my_struct)).should ==
      "typedef struct _my_struct\n{\nint a;\n}\nmy_struct"
  end

  it 'should emit union' do
    @emitter.emit(Sexp.new(:union, :my_union,
                           Sexp.new(:block, Sexp.new(:int, :a)))).should ==
      "union my_union\n{\nint a;\n}"
  end

  it 'should emit prototype' do
    @emitter.emit(Sexp.new(:prototype, :int, :foo,
                           Sexp.new(:abstract_args, Sexp.new(:int, :a)))).should ==
      "int foo(int a)"
  end

  it 'should emit svar_fld' do
    @emitter.emit(Sexp.new(:svar_fld, :my_struct, :my_fld)).should ==
      "my_struct.my_fld"
  end

  it 'should emit svar_fld_ptr' do
    @emitter.emit(Sexp.new(:svar_fld, :my_struct, :my_fld)).should ==
      "my_struct->my_fld"
  end
=end

end
