require 'rspec'
require 'ruby_parser'
require 'sexp_processor'
require 'translator'

describe Translator do
  before do
    @translator = Translator.new
    @rp = RubyParser.new
  end

  # Parses given Ruby code and passes it to the Translator.
  def translate_code(code)
    @translator.translate @rp.parse code
  end

  def translate_code_only(code)
    @translator.send :translate_generic_sexp, @rp.parse(code)
  end

  def simple_type_check(var, type, code)
    @translator.send :add_simple_type_check, var, type, code
  end

  def complex_type_check(var, type2code_hash)
    @translator.send :add_complex_type_check, var, type2code_hash
  end

  # Returns an array of expected included headers
  def includes
    %w/<stdio.h> <rubyc.h>/.map { |h| s(:include, h) }
  end

  # Returns a sexp representing a whole C program with a given body of the
  # 'main' function.
  def program(*body)
    s(:file, *includes, struct_M_Object,
      main(*body))
  end

  # A sexp defining the main object with given fields' declarations.
  def struct_M_Object(*fields_declarations)
      s(:typedef, s(:struct, nil,
        s(:block, s(:decl, :Object, :meta),                       
        *fields_declarations)), :'M_Object')
  end

  # Returns a sexp representing a 'main' function with a given body.
  def main(*body)
    args = s(:abstract_args,
             s(:decl, :int, :argc),
             s(:decl, :'char**', :args))
    s(:defn, :int, :main, args,
      s(:block,
       s(:decl, :'M_Object', :self_s),
       s(:asgn, s(:decl, :'Object*', :self),
         s(:cast, :'Object*', s(:var, :'&self_s'))),
       *body, s(:return, s(:lit, 0))))
  end

  # Returns a sexp representing a call to the Fixnum_new function with a given
  # int value.
  def fixnum_new(value)
    s(:call, :Fixnum_new, s(:args, s(:lit, value)))
  end

  # Returns a sexp representing a call to the boolean_value function with a
  # given value.
  def boolean_value(value)
    s(:call, :boolean_value, s(:args,
                               s(:call, :TO_OBJECT, s(:args, value))))
  end

  # Returns a sexp representing a declaration of a pointer to Object.
  def decl(name)
    s(:decl, :'Object*', name)
  end

  it 'should translate lit' do
    translate_code('69').should == program
  end

  it 'should translate if' do
    translate_code('if 1; 2 end').should ==
      program(decl(:var1),
              s(:if,
                boolean_value(fixnum_new(1)),
                s(:block, s(:asgn, s(:var, :var1), fixnum_new(2)))))
  end

  it 'should translate block' do
    translate_code('4 if 3; 6 if 1;').should ==
      program(decl(:var1),
              s(:if, boolean_value(fixnum_new(3)),
                s(:block, s(:asgn, s(:var, :var1), fixnum_new(4)))),
              decl(:var2),
              s(:if, boolean_value(fixnum_new(1)),
                s(:block, s(:asgn, s(:var, :var2), fixnum_new(6)))))
  end

  it 'should translate unless' do
    translate_code('unless 1; 2 end').should ==
      program(decl(:var1),
             s(:if,
               s(:l_unary_oper, :!, boolean_value(fixnum_new(1))),
               s(:block, s(:asgn, s(:var, :var1), fixnum_new(2)))))
  end

  it 'should translate if else' do
    translate_code('if 1; 2 else 3 end').should ==
      program(decl(:var1),
           s(:if,
             boolean_value(fixnum_new(1)),
             s(:block, s(:asgn, s(:var, :var1), fixnum_new(2))),
             s(:block, s(:asgn, s(:var, :var1), fixnum_new(3)))))
  end

  it 'should translate if elsif' do
    translate_code('if 1; 2 elsif 5; 3 end').should ==
      program(decl(:var1),
              s(:if,
                boolean_value(fixnum_new(1)),
                s(:block, s(:asgn, s(:var, :var1), fixnum_new(2))),
                s(:block,
                  decl(:var2),
                  s(:if,
                    boolean_value(fixnum_new(5)),
                    s(:block, s(:asgn, s(:var, :var2), fixnum_new(3)))
                   ), s(:asgn, s(:var, :var1), s(:var, :var2)))))
  end

  # NOTE: a temporary solution. We need to have Object#== to do it right.
  it 'should translate case with integers only' do
    translate_code('case 4; when 1; 2; when 3; 5; else 6; end').should ==
      program(decl(:var1),
           s(:if,
             #s(:binary_oper, :==, s(:lit, 4), s(:lit, 1)),
             boolean_value(fixnum_new(1)),
             s(:block, s(:asgn, s(:var, :var1), fixnum_new(2))),
             s(:block,
               decl(:var2),
               s(:if,
                 #s(:binary_oper, :==, s(:lit, 4), s(:lit, 3)),
                 boolean_value(fixnum_new(3)),
                 s(:block, s(:asgn, s(:var, :var2), fixnum_new(5))),
                 s(:block, s(:asgn, s(:var, :var2), fixnum_new(6))),
                ), s(:asgn, s(:var, :var1), s(:var, :var2)))))
  end

  it 'should translate while' do
    translate_code('while 1; 2 end').should ==
      program(s(:while, boolean_value(fixnum_new(1)), s(:block)))
  end

  it 'should translate until' do
    translate_code('until 1; 2 end').should ==
      program(s(:while,
                s(:l_unary_oper, :!, boolean_value(fixnum_new(1))),
                s(:block)))
  end

  it 'should detect type of fixnum literal' do
    translate_code_only('2').value_type.should == Fixnum
  end

  it 'should detect type of float literal' do
    translate_code_only('2.5').value_type.should == Float
  end

  it 'should detect type of variable' do
    translate_code_only('b=2')
    translate_code_only('b').value_type.should == Fixnum
  end

  it 'should detect type of a function call returning a constant' do
    translate_code_only('def fun(x); 5.3; end')
    translate_code_only('fun()').value_type.should == Float
  end

  it 'should detect type of a function call returning an argument' do
    translate_code_only('def fun(x); x; end')
    translate_code_only('fun(3.3)').value_type.should == Float
    translate_code_only('fun(2)').value_type.should == Fixnum
  end

  it 'should translate local assignment to new variable' do
    translate_code('b=2').should ==
      program(decl(:b), s(:asgn, s(:var, :b), fixnum_new(2)))
  end

  it 'should translate local assignment to known variable' do
    translate_code_only('b=1')
    translate_code('b=2').should ==
      program(s(:asgn, s(:var, :b), fixnum_new(2)))
  end

  it 'should translate a function without arguments' do
    translate_code('def fun; 5; end; fun').should ==
      s(:file,
        *includes, struct_M_Object,
        s(:prototype, :'Object*', :"M_Object_fun", s(:args, decl(:self))),
        s(:defn, :'Object*', :"M_Object_fun", s(:args, decl(:self)), s(:block,
                                              s(:return, fixnum_new(5)))),
        main(
          decl(:var1),
          s(:asgn, s(:var, :var1), s(:call, :"M_Object_fun", s(:args, s(:var, :self))))))
  end

  it 'should translate a function without arguments called twice' do
    translate_code('def fun; 5; end; fun; fun').should ==
      s(:file,
        *includes, struct_M_Object,
        s(:prototype, :'Object*', :"M_Object_fun", s(:args, decl(:self))),
        s(:defn, :'Object*', :"M_Object_fun", s(:args, decl(:self)), s(:block,
                                              s(:return, fixnum_new(5)))),
        main(
          decl(:var1),
          s(:asgn, s(:var, :var1), s(:call, :"M_Object_fun", s(:args, s(:var, :self)))),
          decl(:var2),
          s(:asgn, s(:var, :var2), s(:call, :"M_Object_fun", s(:args, s(:var, :self))))))
  end

  it 'should translate an assignment to an instance variable' do
    translate_code('@a=@a').should ==
      s(:file,
        *includes, struct_M_Object(decl(:a)),
        main(s(:asgn, s(:binary_oper, :'->', s(:cast, :'M_Object*', s(:var, :self)), s(:var, :a)),
                s(:binary_oper, :'->', s(:cast, :'M_Object*', s(:var, :self)), s(:var, :a)))))
  end

  it 'should add simple type check in the output code' do
    simple_type_check(:b, :Fixnum, s(:lit, 1)).should ==
      s(:stmts,
        s(:decl, :int, :var1),
        s(:if,
           s(:binary_oper, :==, s(:binary_oper, :'->', s(:var, :b), s(:var, :type)),
             s(:lit, 3)),
           s(:block, s(:asgn, s(:var, :var1), fixnum_new(1)))))
  end

  it 'should add complex type check in the output code' do
    complex_type_check(:b, {Fixnum: s(:lit, 1), Object: s(:lit, 2)}).should ==
      s(:stmts,
        s(:decl, :int, :var1),
        s(:switch, s(:binary_oper, :'->', s(:var, :b), s(:var, :type)),
          s(:block,
           s(:case, s(:lit, 3)),
           s(:asgn, s(:var, :var1), fixnum_new(1)),
           s(:break),
           s(:case, s(:lit, 2)),
           s(:asgn, s(:var, :var1), fixnum_new(2)),
           s(:break))))
  end

  it 'should not translate an unsupported construction' do
    $stdout = StringIO.new
    expect do
      translate_code('begin; puts 1; rescue; puts 2; end')
    end .to raise_error
    $stdout = STDOUT
  end

  it 'should not translate an undefined local variable' do
    expect do
      translate_code('puts oh_my_goodness_what_is_that')
    end .to raise_error
  end

  it 'should not translate an undefined function' do
    expect do
      translate_code('there_is_no_such_function(4)')
    end .to raise_error
  end

  it 'should translate a function with arguments' do
    args = s(:args, decl(:self), decl(:x))
    translate_code('def fun(x); x; end; fun 3').should ==
      s(:file,
        *includes, struct_M_Object,
        s(:prototype, :'Object*', :"M_Object_fun_Fixnum", args),
        s(:defn, :'Object*', :"M_Object_fun_Fixnum", args, s(:block,
                                          s(:return, s(:var, :x)))),
        main(
          decl(:var1),
          s(:asgn, s(:var, :var1), s(:call, :"M_Object_fun_Fixnum",
                                     s(:args, s(:var, :self), fixnum_new(3))))))
  end

  it 'should translate class declaration' do
    translate_code('class A; def initialize(a); @a=a; end; end; A.new(1)').should ==
      s(:file,
        *includes, struct_M_Object,
        s(:typedef,
          s(:struct, nil,
            s(:block, s(:decl, :Object, :meta), decl(:a))), :A),
        s(:prototype, :'Object*', :A_initialize_Fixnum, s(:args, decl(:self), decl(:a))),
        s(:prototype, :'Object*', :A_new_Fixnum, s(:args, decl(:a))),
        s(:defn, :'Object*', :A_initialize_Fixnum, s(:args, decl(:self), decl(:a)),
          s(:block,
            s(:asgn,
               s(:binary_oper, :'->', s(:cast, :'A*', s(:var, :self)), s(:var, :a)), s(:var, :a)),
            s(:return, s(:binary_oper, :'->', s(:cast, :'A*', s(:var, :self)), s(:var, :a))))),
        s(:defn, :'Object*', :A_new_Fixnum, s(:args, decl(:a)),
          s(:block,
            s(:asgn, decl(:self),
              s(:call, :xmalloc,
                s(:args, s(:call, :sizeof, s(:args, s(:lit, :A)))))),
            s(:asgn,
              s(:binary_oper, :'->', s(:var, :self), s(:var, :type)), s(:lit, 5)),
                s(:call, :A_initialize_Fixnum, s(:args, s(:var, :self), s(:var, :a))),
            s(:return, s(:var, :self)))),
        main(
         decl(:var1),
         s(:asgn, s(:var, :var1),
         s(:call, :'A_new_Fixnum', s(:args, fixnum_new(1))))))
  end

end
