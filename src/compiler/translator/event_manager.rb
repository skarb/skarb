# Class providing simple event mechanism. Event handlers are registered
# through public 'subscribe' method, event sender notify subscribers through
# 'fire_event'. 
class EventManager < Hash

   attr_reader :active

   def initialize
      super
      @active = true
   end

   def subscribe(event, method)
      (self[event] ||= []).push method
   end

   def fire_event(event, event_struct)
      return unless @active

      if include? event  
         self[event].each do |x|
            x.call(event_struct)
         end
      end
   end

   def activate
      @active = true
   end

   def deactivate
      @active = false
   end

end
