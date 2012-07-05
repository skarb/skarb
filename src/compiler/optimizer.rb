require 'sexp_processor'
require 'translator/translated_sexp_dictionary'
require 'optimizations/math_inliner'
require 'optimizations/connection_graph_builder'

# Responsible for managing various optimization classes.  
class Optimizer

   def initialize(translator, options)
      #@translator = translator
      if options[:stack_alloc]
         @connection_graph_builder = ConnectionGraphBuilder.new(translator)
      end
      if options[:math_inline]
         @math_inliner = MathInliner.new(translator)
      end
   end

end
