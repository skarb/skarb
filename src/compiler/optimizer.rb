require 'sexp_processor'
require 'translator/translated_sexp_dictionary'
require 'optimizations/math_inliner'
require 'optimizations/connection_graph_builder'

# Responsible for managing various optimization classes.  
class Optimizer

   def initialize(translator)
      @translator = translator
      @math_inliner = MathInliner.new(translator)
      @connection_graph_builder = ConnectionGraphBuilder.new(translator)
   end

end
