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

##################################################################################
# (C) 2010-2012 Jan Stępień, Julian Zubek
# 
# This file is a part of Skarb -- Ruby to C compiler.
# 
# Skarb is free software: you can redistribute it and/or modify it under the terms
# of the GNU Lesser General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later
# version.
# 
# Skarb is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
# PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
# 
# You should have received a copy of the GNU Lesser General Public License along
# with Skarb. If not, see <http://www.gnu.org/licenses/>.
# 
##################################################################################
