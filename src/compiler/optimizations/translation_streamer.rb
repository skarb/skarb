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
      @event_manager = EventManager.new
      
      translator.subscribe_all(self.method(:sexp_translated))
      
      s_table = translator.symbol_table
      s_table.subscribe(:function_opened, self.method(:function_opened))
      s_table.subscribe(:function_closed, self.method(:function_closed))      
      s_table.subscribe(:cfunction_changed, self.method(:cfunction_changed))      
   end

   def subscribe(event, method)
      @event_manager.subscribe(event, method)
   end

   # Translated sexp returned by translator function is always s(:stmts, ...)
   # wrapper or empty s(). Because of this, traversal should be started on the
   # lower level.
   def sexp_translated(event)
      if event.translated_sexp
         event.translated_sexp.each do |t_sexp|
            traverse_sexp(t_sexp, event.original_sexp)
         end
      end
   end

   def function_opened(event)
      @event_manager.fire_event(:function_opened, event)
   end

   def function_closed(event)
      @event_manager.fire_event(:function_closed, event)
   end

   def cfunction_changed(event)
      @cfunction = event.new_value
      @event_manager.fire_event(:cfunction_changed, event)
   end

   # Traverses translated C sexp and fires appropriate event for each of its
   # children. To ensure that there will be no duplicates, s(:stmts) sexps are
   # not explored (they already were).
   def traverse_sexp(sexp, original_sexp)
      if sexp.is_a? Sexp and sexp[0] != :stmts
         
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

end
