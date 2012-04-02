class MemoryAllocator
   # Local symbol table for MemoryAllocator purposes. It stores connection graph
   # nodes organized by class, function and block (just like in global symbol
   # table used by translator).  
   class LocalTable < Hash
      
      attr_reader :cclass, :cfunction
  
      def synchronize(symbol_table) 
         self.cclass = symbol_table.cclass
         self.cfunction = symbol_table.cfunction
      end

      def add_function(f_name)
         self[@cclass][:functions][fname] = {
            :lvars => {},
            :last_block => nil
         }
      end

      def add_class(class_name)
         self[class_name] = {
            :functions => {},
            :ivars => {},
            :cvars => {}
         } 
      end

      def cclass=(class_name)
         @cclass = class_name
         add_class(@cclass) unless self.has_key? @cclass
      end

      def cfunction=(f_name)
         @cfunction = f_name
         add_function(@cfunction) unless self[@cclass].has_key? @cfunction
      end

      def open_block
         last_block = { :lvars => {}, :parent => last_block }
      end

      def close_block
         # TODO: Merge blocks contents
         last_block = last_block[:parent]
      end

      def last_block
         self[@cclass][:functions][@cfunction][:last_block]
      end

      def last_block=(val)
         self[@cclass][:functions][@cfunction][:last_block] = val
      end

   end
end
