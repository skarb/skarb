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
    @translator._translate_generic_debug @rp.parse code
  end

  # Returns a sexp representing a 'main' function with a given body.
  def main(*body)
    args = s(:abstract_args,
             s(:decl, :int, :argc),
             s(:decl, :'char**', :args))
    s(:defn, :int, :main, args, s(:block, *body, s(:return, s(:lit, 0))))
  end

  it 'should translate lit' do
    translate_code('69').should == main
  end

  it 'should translate if' do
    translate_code('if 1; 2 end').should ==
      main(s(:decl, :int, :var1),
           s(:if,
             s(:lit, 1),
             s(:block, s(:asgn, s(:var, :var1), s(:lit, 2)))))
  end

  it 'should translate block' do
    translate_code('4 if 3; 6 if 1;').should ==
      main(s(:decl, :int, :var1),
           s(:if, s(:lit, 3), s(:block, s(:asgn, s(:var, :var1), s(:lit, 4)))),
           s(:decl, :int, :var2),
           s(:if, s(:lit, 1), s(:block, s(:asgn, s(:var, :var2), s(:lit, 6)))))
  end

  it 'should translate unless' do
    translate_code('unless 1; 2 end').should ==
      main(s(:decl, :int, :var1),
           s(:if,
             s(:l_unary_oper, :!, s(:lit, 1)),
             s(:block, s(:asgn, s(:var, :var1), s(:lit, 2)))))
  end

  it 'should translate if else' do
    translate_code('if 1; 2 else 3 end').should ==
      main(s(:decl, :int, :var1),
           s(:if,
             s(:lit, 1),
             s(:block, s(:asgn, s(:var, :var1), s(:lit, 2))),
             s(:block, s(:asgn, s(:var, :var1), s(:lit, 3)))))
  end

  it 'should translate if elsif' do
    translate_code('if 1; 2 elsif 5; 3 end').should ==
      main(s(:decl, :int, :var1),
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
      main(s(:decl, :int, :var1),
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
      main(s(:while, s(:lit, 1), s(:block)))
  end

  it 'should translate until' do
    translate_code('until 1; 2 end').should ==
      main(s(:while, s(:l_unary_oper, :!, s(:lit, 1)), s(:block)))
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
      main(s(:decl, :int, :b), s(:asgn, s(:var, :b), s(:lit, 2)))
  end

  it 'should translate local assignment to known variable' do
    translate_code_only('b=1')
    translate_code('b=2').should ==
      main(s(:asgn, s(:var, :b), s(:lit, 2)))
  end

end
