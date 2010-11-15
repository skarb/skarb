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
    s(:defn, :int, :main, args, s(:block, *body))
  end

  it 'should translate lit' do
    translate_code('69').should == main(s(:return, s(:lit, 69)))
  end

  it 'should translate if' do
    translate_code('if 1; 2 end').should ==
      main(s(:decl, :int, :var1),
           s(:if,
             s(:lit, 1),
             s(:block, s(:asgn, s(:var, :var1), s(:lit, 2)))
            ), s(:return, :var1))
  end

  it 'should translate if else' do
    translate_code('if 1; 2 else 3 end').should ==
      main(s(:decl, :int, :var1),
           s(:if,
             s(:lit, 1),
             s(:block, s(:asgn, s(:var, :var1), s(:lit, 2))),
             s(:block, s(:asgn, s(:var, :var1), s(:lit, 3))),
            ), s(:return, :var1))
  end

  it 'should detect type of fixnum literal' do
    translate_code_only('2').value_types.first.should == :Fixnum
  end

  it 'should detect type of float literal' do
    translate_code_only('2.5').value_types.first.should == :Float
  end

  it 'should detect type of variable' do
    translate_code_only('b=2')
    translate_code_only('b').value_types.first.should == :Fixnum
  end

end
