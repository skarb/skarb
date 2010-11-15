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

  it 'should translate while' do
    translate_code('while 1; 2 end').should ==
      main(s(:while, s(:lit, 1), s(:block)))
  end
end
