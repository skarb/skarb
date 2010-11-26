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
    [s(:include, '<stdio.h>'),
      s(:include, '"objects.h"')]
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

  it 'should translate lit' do
    translate_code('69').should == program
  end

  it 'should translate if' do
    translate_code('if 1; 2 end').should ==
      program(s(:decl, :int, :var1),
           s(:if,
             s(:lit, 1),
             s(:block, s(:asgn, s(:var, :var1), s(:lit, 2)))))
  end

  it 'should translate block' do
    translate_code('4 if 3; 6 if 1;').should ==
      program(s(:decl, :int, :var1),
           s(:if, s(:lit, 3), s(:block, s(:asgn, s(:var, :var1), s(:lit, 4)))),
           s(:decl, :int, :var2),
           s(:if, s(:lit, 1), s(:block, s(:asgn, s(:var, :var2), s(:lit, 6)))))
  end

  it 'should translate unless' do
    translate_code('unless 1; 2 end').should ==
      program(s(:decl, :int, :var1),
           s(:if,
             s(:l_unary_oper, :!, s(:lit, 1)),
             s(:block, s(:asgn, s(:var, :var1), s(:lit, 2)))))
  end

  it 'should translate if else' do
    translate_code('if 1; 2 else 3 end').should ==
      program(s(:decl, :int, :var1),
           s(:if,
             s(:lit, 1),
             s(:block, s(:asgn, s(:var, :var1), s(:lit, 2))),
             s(:block, s(:asgn, s(:var, :var1), s(:lit, 3)))))
  end

  it 'should translate if elsif' do
    translate_code('if 1; 2 elsif 5; 3 end').should ==
      program(s(:decl, :int, :var1),
           s(:if,
             s(:lit, 1),
             s(:block, s(:asgn, s(:var, :var1), s(:lit, 2))),
             s(:block,
               s(:decl, :int, :var2),
               s(:if,
                 s(:lit, 5),
                 s(:block, s(:asgn, s(:var, :var2), s(:lit, 3)))
                ), s(:asgn, s(:var, :var1), s(:var, :var2)))))
  end

  # NOTE: a temporary solution. We need to have Object#== to do it right.
  it 'should translate case with integers only' do
    translate_code('case 4; when 1; 2; when 3; 5; else 6; end').should ==
      program(s(:decl, :int, :var1),
           s(:if,
             #s(:binary_oper, :==, s(:lit, 4), s(:lit, 1)),
             s(:lit, 1),
             s(:block, s(:asgn, s(:var, :var1), s(:lit, 2))),
             s(:block,
               s(:decl, :int, :var2),
               s(:if,
                 #s(:binary_oper, :==, s(:lit, 4), s(:lit, 3)),
                 s(:lit, 3),
                 s(:block, s(:asgn, s(:var, :var2), s(:lit, 5))),
                 s(:block, s(:asgn, s(:var, :var2), s(:lit, 6))),
                ), s(:asgn, s(:var, :var1), s(:var, :var2)))))
  end

  it 'should translate while' do
    translate_code('while 1; 2 end').should ==
      program(s(:while, s(:lit, 1), s(:block)))
  end

  it 'should translate until' do
    translate_code('until 1; 2 end').should ==
      program(s(:while, s(:l_unary_oper, :!, s(:lit, 1)), s(:block)))
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
      program(s(:decl, :int, :b), s(:asgn, s(:var, :b), s(:lit, 2)))
  end

  it 'should translate local assignment to known variable' do
    translate_code_only('b=1')
    translate_code('b=2').should ==
      program(s(:asgn, s(:var, :b), s(:lit, 2)))
  end

  it 'should translate a function without arguments' do
    translate_code('def fun; 5; end; fun').should ==
      s(:file,
        *includes,
        s(:prototype, :int, :fun, s(:args)),
        s(:defn, :int, :fun, s(:args), s(:block, s(:return, s(:lit, 5)))),
        main(
          s(:decl, :int, :var1),
          s(:asgn, s(:var, :var1), s(:call, :fun, s(:args)))))
  end

  it 'should translate a function without arguments called twice' do
    translate_code('def fun; 5; end; fun; fun').should ==
      s(:file,
        *includes,
        s(:prototype, :int, :fun, s(:args)),
        s(:defn, :int, :fun, s(:args), s(:block, s(:return, s(:lit, 5)))),
        main(
          s(:decl, :int, :var1),
          s(:asgn, s(:var, :var1), s(:call, :fun, s(:args))),
          s(:decl, :int, :var2),
          s(:asgn, s(:var, :var2), s(:call, :fun, s(:args)))))
  end

  it 'should add simple type check in the output code' do
    simple_type_check(:b, :Fixnum, s(:lit, 1)).should ==
      s(:stmts,
        s(:decl, :int, :var1),
        s(:if,
           s(:binary_oper, s(:binary_oper, s(:var, :b), :'.', s(:var, :type)),
             :==, s(:lit, 2)),
           s(:block, s(:asgn, s(:var, :var1), s(:lit, 1)))))
  end

  it 'should add complex type check in the output code' do
    complex_type_check(:b, {Fixnum: s(:lit, 1), Object: s(:lit, 2)}).should ==
      s(:stmts,
        s(:decl, :int, :var1),
        s(:switch, s(:binary_oper, s(:var, :b), :'.', s(:var, :type)),
          s(:block,
           s(:case, s(:lit, 2)),
           s(:asgn, s(:var, :var1), s(:lit, 1)),
           s(:break),
           s(:case, s(:lit, 1)),
           s(:asgn, s(:var, :var1), s(:lit, 2)),
           s(:break))))
  end
end
