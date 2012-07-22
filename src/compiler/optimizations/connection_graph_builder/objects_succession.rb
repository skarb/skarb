class ConnectionGraphBuilder
   module ObjectsSuccession
      
      ObjectLife = Struct.new(:id, :constructor_sexp, :potential_precursors)

      # Finds objects which are pontential successors of given object.
      def find_candidates(object, remaining_objects)
         return remaining_objects if object.nil?
         remaining_objects.select { |c| c.potential_precursors.include? object.id }
      end

      # Finds an object with earliest death stamp.
      def find_erliest_death(objects)
         objects.reduce { |acc, o| o.death < acc.death ? o : acc }
      end

      # Determines optimal succession lines of the objects by recursively
      # searching solution space. Succession line is an array of objects using
      # the same memory unit. When memory allocated for objects is not reused,
      # each object belongs to its own succession line. The goal is to create
      # as few succession lines as possible.
      def find_succession(succ_lines, remaining_objects, current_line,
                          best_lines)
         return best_lines if succ_lines.length > best_lines.length
         if remaining_objects.empty?
            succ_lines = succ_lines + [current_line] unless current_line.empty?
            return succ_lines 
         end

         candidates = find_candidates(current_line.last, remaining_objects)
         if candidates.empty?
            return find_succession(succ_lines + [current_line],
                                   remaining_objects, [],
                                   best_lines)
         else
            candidates.each do |c|
               r = find_succession(succ_lines, remaining_objects - [c],
                                   current_line + [c], best_lines)
               best_lines = r if best_lines.length > r.length 
            end
            return best_lines
         end
      end

      # Convenient entry for find_succession
      def find_objects_succession(objects)
         initial_best = objects.map { |o| [o] }
         find_succession([], objects, [], initial_best)
      end
   end
end

#ObjectLife = Struct.new(:id, :type, :birth, :death)

#o1 = ObjectLife.new(:o1, :Fixnum, 1, 3)
#o2 = ObjectLife.new(:o2, :Fixnum, 2, 5)
#o3 = ObjectLife.new(:o3, :Fixnum, 6, 7)
#o4 = ObjectLife.new(:o4, :Fixnum, 4, 8)

#p find_object_succession([], [o1,o2,o3,o4], [],
#                         [[o1],[o2],[o3],[o4]])
