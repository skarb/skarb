# Class providing simple event mechanism. Event handlers are registered
# through public 'subscribe' method, event sender notify subscribers through
# 'fire_event'. 
class EventManager < Hash

   def subscribe(event, method)
      (self[event] ||= []).push method
   end

   def fire_event(event, event_struct)
      if include? event  
         self[event].each do |x|
            x.call(event_struct)
         end
      end
   end

end
