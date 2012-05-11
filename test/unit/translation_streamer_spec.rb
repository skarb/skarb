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
    @streamer.subscribe(:block_opened, self.method(:block_opened))
    @streamer.subscribe(:block_closed, self.method(:block_closed))
    @streamer.subscribe(:cfunction_changed, self.method(:cfunction_changed))
    @lit_count = 0
    @opened = 0
    @closed = 0
    @functions = []
  end

  def lit_translated(event)
    @lit_count += 1
    p event.sexp
  end

  def block_opened(event)
    @opened += 1
  end

  def block_closed(event)
    @closed += 1
  end

  def cfunction_changed(event)
    @functions << event.new_value
    puts "#{event.old_value} -> #{event.new_value}"
  end

  it 'should fire event for every C sexp in translated code' do
    @translator.translate(Parser.parse("1"))
    @lit_count.should > 0
  end

  it 'should generate block events' do
    @translator.translate(Parser.parse("if 1; a = 1; else; a = 2; end"))
    @opened.should == 2
    @closed.should == 2
  end

  it 'should keep track of current function context' do
    @translator.translate(Parser.parse("a = 10; def foo; a = 20; end; a = 30; def bar; foo; end; a = 40"))
    @functions.should == [:M_Object_foo, :M_Object_bar] 
  end

end
