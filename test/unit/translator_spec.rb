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
    s(:file,
      *includes,
      main(*body))
  end

  # Returns a sexp representing a 'main' function with a given body.
  def main(*body)
    args = s(:abstract_args,
             s(:decl, :int, :argc),
             s(:decl, :'char**', :args))
    s(:defn, :int, :main, args, s(:block, *body, s(:return, s(:lit, 0))))
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

  # Returns a sexp representing a declaration of a pointer to Fixnum.
  def decl_fixnum(name)
    s(:decl, 'Fixnum*', name)
  end

  it 'should translate lit' do
    translate_code('69').should == program
  end

  it 'should translate if' do
    translate_code('if 1; 2 end').should ==
      program(decl_fixnum(:var1),
              s(:if,
                boolean_value(fixnum_new(1)),
                s(:block, s(:asgn, s(:var, :var1), fixnum_new(2)))))
  end

  it 'should translate block' do
    translate_code('4 if 3; 6 if 1;').should ==
      program(decl_fixnum(:var1),
              s(:if, boolean_value(fixnum_new(3)),
                s(:block, s(:asgn, s(:var, :var1), fixnum_new(4)))),
              decl_fixnum(:var2),
              s(:if, boolean_value(fixnum_new(1)),
                s(:block, s(:asgn, s(:var, :var2), fixnum_new(6)))))
  end

  it 'should translate unless' do
    translate_code('unless 1; 2 end').should ==
      program(decl_fixnum(:var1),
             s(:if,
               s(:l_unary_oper, :!, boolean_value(fixnum_new(1))),
               s(:block, s(:asgn, s(:var, :var1), fixnum_new(2)))))
  end

  it 'should translate if else' do
    translate_code('if 1; 2 else 3 end').should ==
      program(decl_fixnum(:var1),
           s(:if,
             boolean_value(fixnum_new(1)),
             s(:block, s(:asgn, s(:var, :var1), fixnum_new(2))),
             s(:block, s(:asgn, s(:var, :var1), fixnum_new(3)))))
  end

  it 'should translate if elsif' do
    translate_code('if 1; 2 elsif 5; 3 end').should ==
      program(decl_fixnum(:var1),
              s(:if,
                boolean_value(fixnum_new(1)),
                s(:block, s(:asgn, s(:var, :var1), fixnum_new(2))),
                s(:block,
                  decl_fixnum(:var2),
                  s(:if,
                    boolean_value(fixnum_new(5)),
                    s(:block, s(:asgn, s(:var, :var2), fixnum_new(3)))
                   ), s(:asgn, s(:var, :var1), s(:var, :var2)))))
  end

  # NOTE: a temporary solution. We need to have Object#== to do it right.
  it 'should translate case with integers only' do
    translate_code('case 4; when 1; 2; when 3; 5; else 6; end').should ==
      program(decl_fixnum(:var1),
           s(:if,
             #s(:binary_oper, :==, s(:lit, 4), s(:lit, 1)),
             boolean_value(fixnum_new(1)),
             s(:block, s(:asgn, s(:var, :var1), fixnum_new(2))),
             s(:block,
               decl_fixnum(:var2),
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
    translate_code_only('2').value_types.first.should == Fixnum
  end

  it 'should detect type of float literal' do
    translate_code_only('2.5').value_types.first.should == Float
  end

  it 'should detect type of variable' do
    translate_code_only('b=2')
    translate_code_only('b').value_types.first.should == Fixnum
  end

  it 'should translate local assignment to new variable' do
    translate_code('b=2').should ==
      program(decl_fixnum(:b), s(:asgn, s(:var, :b), fixnum_new(2)))
  end

  it 'should translate local assignment to known variable' do
    translate_code_only('b=1')
    translate_code('b=2').should ==
      program(s(:asgn, s(:var, :b), fixnum_new(2)))
  end

  it 'should translate a function without arguments' do
    translate_code('def fun; 5; end; fun').should ==
      s(:file,
        *includes,
        s(:prototype, 'Fixnum*', :_fun, s(:args)),
        s(:defn, 'Fixnum*', :_fun, s(:args), s(:block,
                                              s(:return, fixnum_new(5)))),
        main(
          decl_fixnum(:var1),
          s(:asgn, s(:var, :var1), s(:call, :_fun, s(:args)))))
  end

  it 'should translate a function without arguments called twice' do
    translate_code('def fun; 5; end; fun; fun').should ==
      s(:file,
        *includes,
        s(:prototype, 'Fixnum*', :_fun, s(:args)),
        s(:defn, 'Fixnum*', :_fun, s(:args), s(:block,
                                              s(:return, fixnum_new(5)))),
        main(
          decl_fixnum(:var1),
          s(:asgn, s(:var, :var1), s(:call, :_fun, s(:args))),
          decl_fixnum(:var2),
          s(:asgn, s(:var, :var2), s(:call, :_fun, s(:args)))))
  end

  it 'should translate an assignment to an instance variable' do
    translate_code('@a=@a').should ==
      program(s(:asgn, s(:binary_oper, :'->', s(:var, :self), s(:var, :a)),
       s(:binary_oper, :'->', s(:var, :self), s(:var, :a))))
  end

  it 'should add simple type check in the output code' do
    simple_type_check(:b, :Fixnum, s(:lit, 1)).should ==
      s(:stmts,
        s(:decl, :int, :var1),
        s(:if,
           s(:binary_oper, :==, s(:binary_oper, :'->', s(:var, :b), s(:var, :type)),
             s(:lit, 2)),
           s(:block, s(:asgn, s(:var, :var1), fixnum_new(1)))))
  end

  it 'should add complex type check in the output code' do
    complex_type_check(:b, {Fixnum: s(:lit, 1), Object: s(:lit, 2)}).should ==
      s(:stmts,
        s(:decl, :int, :var1),
        s(:switch, s(:binary_oper, :'->', s(:var, :b), s(:var, :type)),
          s(:block,
           s(:case, s(:lit, 2)),
           s(:asgn, s(:var, :var1), fixnum_new(1)),
           s(:break),
           s(:case, s(:lit, 1)),
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

  it 'should not translate a puts with puts as an argument' do
    expect { translate_code('puts puts 3') } .to raise_error
  end

  it 'should not translate an undefined function' do
    expect do
      translate_code('there_is_no_such_function(4)')
    end .to raise_error
  end

  it 'should translate a function with arguments' do
    args = s(:args, s(:decl, 'Fixnum*', :x))
    translate_code('def fun(x); x; end; fun 3').should ==
      s(:file,
        *includes,
        s(:prototype, 'Fixnum*', :_Fixnum_fun, args),
        s(:defn, 'Fixnum*', :_Fixnum_fun, args, s(:block,
                                          s(:return, s(:var, :x)))),
        main(
          decl_fixnum(:var1),
          s(:asgn, s(:var, :var1), s(:call, :_Fixnum_fun,
                                     s(:args, fixnum_new(3))))))
  end
end
