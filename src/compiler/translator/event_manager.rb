# Copyright (c) 2010-2012 Jan Stępień, Julian Zubek
#
# This file is a part of Skarb -- a Ruby to C compiler.
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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
