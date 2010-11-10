require 'rspec'
require 'emitter'
require 'sexp_processor'

describe Emitter do
  before do
    @emitter = Emitter.new
    @hellow_body = Sexp.new(:block)
    @hellow_main = Sexp.new(:defn, :int, :main, Sexp.new(:args, Sexp.new(:int, :argc),
	Sexp.new(:'char**', :args)), Sexp.new(:scope, @hellow_body))
    @hellow_body.push(Sexp.new(:call, :printf, Sexp.new(:arglist, Sexp.new(:str, "Hello world!"))))
    @hellow_body.push(Sexp.new(:return, Sexp.new(:lit, 0)))
  end

  it 'should emit a hello world' do
    @emitter.emit(@hellow_main).should ==
      "int main(int argc, char** args)\n{\nprintf(\"Hello world!\");\nreturn 0;\n}\n"
  end
end
