require 'sexp_processor'
require 'translator/translated_sexp_dictionary'
require 'optimizations/math_inliner'

# Responsible for managing various optimization classes.  
class Optimizer

   def initialize(translator)
      @translator = translator
      @math_inliner = MathInliner.new(translator.symbol_table)
   end

   def subscribe_to_events
      @translator.subscribe(:call_translated, @math_inliner.method(:call_translated))
   end

end
