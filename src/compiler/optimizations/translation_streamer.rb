require 'sexp_processor'
require 'translator/event_manager'

# This class receives all sexps translated by the translator, goes through the
# translated code and fires event for each translated C code sexp. It also can
# tell at any given moment to which function C streamed code belongs (it is
# non-trivial, because code is streamed in execution order, not structural order).
class TranslationStreamer

   EventStruct = Struct.new(:sexp, :original_sexp)

   attr_reader :cfunction

   def initialize(translator)
      @s_table = translator.symbol_table
      @event_manager = EventManager.new
      translator.subscribe(:generic_sexp_translated, self.method(:sexp_translated))
      @s_table.subscribe(:function_opened, self.method(:function_opened))
      @s_table.subscribe(:function_closed, self.method(:function_closed))      
      @s_table.subscribe(:cfunction_changed, self.method(:cfunction_changed))      
   end

   def subscribe(event, method)
      @event_manager.subscribe(event, method)
   end

   def sexp_translated(event)
      traverse_sexp(event.translated_sexp, event.original_sexp)
   end

   def function_opened(event)
      @event_manager.fire_event(:function_opened, nil)
   end

   def function_closed(event)
      @event_manager.fire_event(:function_closed, nil)
   end

   def cfunction_changed(event)
      @cfunction = event.new_value
      @event_manager.fire_event(:cfunction_changed, event)
   end

   # Traverses translated C sexp and fires appropriate event for each of its
   # children. To ensure that there will be no duplicates, each visited sexp
   # is marked.
   def traverse_sexp(sexp, original_sexp)
      if sexp.is_a? Sexp and !sexp.marked?
   
         mark_sexp(sexp)

         if sexp[0] == :block
            @event_manager.fire_event(:block_opened, nil)
         end

         sexp.each { |a| traverse_sexp(a, original_sexp) }

         if sexp[0] == :block
            @event_manager.fire_event(:block_closed, nil)
         end

         @event_manager.fire_event("#{sexp[0]}_translated".to_sym,
                                   EventStruct.new(sexp, original_sexp)) 
      end 
   end

   # All sexp are initially not marked.
   def Sexp.marked?
      false
   end

   # This method marks sexp by redefining its "marked?" method.
   def mark_sexp(sexp)
      def sexp.marked?
         true
      end
   end

end
