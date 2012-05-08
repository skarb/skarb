require 'sexp_processor'
require 'translator/event_manager'

# This class receives all sexps translated by the translator, goes through the
# translated code and fires event for each translated C code sexp. 
class TranslationStreamer

   EventStruct = Struct.new(:sexp, :original_sexp)

   def initialize(translator)
      @translator = translator
      @event_manager = EventManager.new
      @translator.subscribe(:generic_sexp_translated, self.method(:sexp_translated))
   end

   def subscribe(event, method)
      @event_manager.subscribe(event, method)
   end

   def sexp_translated(event)
      traverse_sexp(event.translated_sexp, event.original_sexp)
   end

   def traverse_sexp(sexp, original_sexp)
      if sexp.is_a? Sexp
         sexp.each { |a| traverse_sexp(a, original_sexp) }
         @event_manager.fire_event("#{sexp[0]}_translated".to_sym,
                                   EventStruct.new(sexp, original_sexp)) 
      end 
   end

end
