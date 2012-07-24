# Class providing simple event mechanism. Event handlers are registered
# through public 'subscribe' method, event sender notify subscribers through
# 'fire_event'. 
class EventManager < Hash

   attr_reader :active

   def initialize
      super
      @active = true
      @all_events = []
   end

   def subscribe(event, method)
      (self[event] ||= []).push method
   end

   def subscribe_all(method)
      @all_events.push method
   end

   def fire_event(event, event_struct)
      return unless @active

      if include? event  
         self[event].each { |x| x.call(event_struct) }
      end
      @all_events.each { |x| x.call(event_struct) }
   end

   def activate
      @active = true
   end

   def deactivate
      @active = false
   end

end
