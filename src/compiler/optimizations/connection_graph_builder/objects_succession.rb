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

##################################################################################
# (C) 2012 Julian Zubek
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
