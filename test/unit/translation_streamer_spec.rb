require 'rspec'
require 'set'
require 'translator'
require 'parser'
require 'optimizations/translation_streamer'

describe TranslationStreamer do
  before do
    @translator = Translator.new
    @streamer = TranslationStreamer.new(@translator)
    @streamer.subscribe(:lit_translated, self.method(:lit_translated))
  end

  def lit_translated(event)
    @lit_count += 1
  end

  it 'should fire event for every C sexp in translated code' do
    @lit_count = 0
    @translator.translate(Parser.parse("1"))
    @lit_count.should > 0
  end
end
