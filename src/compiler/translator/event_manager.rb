# Class providing simple event mechanism for Translator. After translation
# of sexp 'fire_event' is called. Event handlers are registered through public
# 'subscribe' method. 
class Translator
   class EventManager < Hash

      # event -- original sexp type
      # sender -- Translator instance
      EventStruct = Struct.new(:event, :sender, :original_sexp, :translated_sexp)

      def subscribe(event, method)
         (self[event] ||= []).push method
      end

      def fire_event(event, sender, orig_sexp, trans_sexp)
         if include? event  
            self[event].each do |x|
               x.call(EventStruct.new(event, sender, orig_sexp, trans_sexp))
            end
         end
      end

   end
end
