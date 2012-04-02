class MemoryAllocator
   # Local symbol table for MemoryAllocator purposes. It stores connection graph
   # nodes organized by class, function and block (just like in global symbol
   # table used by translator).
   class LocalTable < Hash
      
      attr_reader :cclass, :cfunction
 
      # Synchronizes current class and function with another symbol table. 
      def synchronize(symbol_table) 
         self.cclass = symbol_table.cclass
         self.cfunction = symbol_table.cfunction
      end

      # Adds new function in current class context with mandatory keys.
      def add_function(f_name)
         self[@cclass][fname] = {
            :lvars => {},
            :ivars => {},
            :cvars => {},
            :last_block => nil
         }
      end

      # Adds new class with mandatory keys.
      def add_class(class_name)
         self[class_name] = {} 
      end

      # Current class setter. Creates new class if necessary.
      def cclass=(class_name)
         @cclass = class_name
         add_class(@cclass) unless self.has_key? @cclass
      end

      # Current function setter. Creates new function if necessary.
      def cfunction=(f_name)
         @cfunction = f_name
         add_function(@cfunction) unless self[@cclass].has_key? @cfunction
      end

      # Opens new block representing conditional program branch.
      def open_block
         last_block = { :lvars => {}, :parent => last_block }
      end

      # Closes block and merges conditional branches by merging nodes of
      # corresponding variables.
      def close_block
         # TODO: Merge blocks contents
         last_block = last_block[:parent]
      end

      # Last opened block getter.
      def last_block
         self[@cclass][@cfunction][:last_block]
      end

      # Last opened block setter.
      def last_block=(val)
         self[@cclass][@cfunction][:last_block] = val
      end

      private

      # Searches for variable by traversing up the block structure and
      # returns graph node corresponding to it. If no node can be found new
      # a one is created. Key can be :lvars, :ivars or :cvars.
      def get_var_node(var, key)
         cblock = last_block
         begin
            return cblock[key][var] if cblock[key].has_key? var
         end until cblock[:parent].nil?
         last_block[key][var] = Node.new 
      end

      # Copies variable node and places the copy in the last block. It is necessary
      # to do so before assigment to variable. Key can be :lvar, :ivar or :cvar.
      def copy_var_node(var, key)
         # If lvar is defined in the last block it is unnecessary to copy it's node.
         return last_block[key][var] if last_block[key].has_key? var
         last_block[key][var] = get_var_node(var, key).clone
      end

      public

      def get_lvar_node(var)
         get_var_node(var, :lvars)
      end

      def get_ivar_node(var)
         get_var_node(var, :ivars)
      end

      def get_cvar_node(var)
         get_var_node(var, :cvars)
      end

      def copy_lvar_node(var)
         copy_var_node(var, :lvars)
      end

      def copy_ivar_node(var)
         copy_var_node(var, :ivars)
      end

      def copy_cvar_node(var)
         copy_var_node(var, :cvars)
      end

   end
end
