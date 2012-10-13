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

require 'set'

class ConnectionGraphBuilder
   module ObjectsSuccession
      
      ObjectLife = Struct.new(:id, :constructor_sexp, :potential_precursors,
                              :inside_loop)

      Pair = Struct.new(:a, :b)

      def find_successors(object, remaining_objects)
         return remaining_objects if object.nil?
         remaining_objects.select { |c| c.potential_precursors.include? object.id }
      end

      def find_best_successor(object, remaining_objects)
         successors = find_successors(object, remaining_objects)
         return nil if successors.empty?
         best_successor = successors.reduce(Pair.new(nil,-1)) do |acc,o|
            n = find_successors(o, remaining_objects).length
            n > acc.b ? Pair.new(o,n) : acc
         end
         best_successor.a
      end

      # Determines succession lines of the objects in greedy way.
      # Succession line is an array of objects using
      # the same memory unit. When memory allocated for objects is not reused,
      # each object belongs to its own succession line. The goal is to create
      # as few succession lines as possible.
      def find_succession(succ_lines, remaining_objects, current_line)
         if remaining_objects.empty?
            if current_line.empty?
               return succ_lines
            else
               return succ_lines + [current_line]
            end
         end
         succ = find_best_successor(current_line.last, remaining_objects)
         return find_succession(succ_lines + [current_line], remaining_objects, []) if succ.nil?
         return find_succession(succ_lines, remaining_objects - [succ], current_line + [succ])
      end

      # Convenient entry for find_succession
      def find_objects_succession(objects)
         find_succession([], objects, [])
      end

   end
end
