require 'rspec'
require 'emitter'
require 'sexp_processor'

describe Emitter do
  before do
    @emitter = Emitter.new
  end

  it 'should emit a hello world' do
    @emitter.emit(Sexp.new('foobar')).should ==
      "int main(){return 0;}"
  end
end
