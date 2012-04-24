require 'sexp_processor'

# Functions that help extracting specific elements from sexps.
module SexpParsing
  
   def lasgn_get_var(sexp)
      sexp[1]
   end
 
   def lasgn_get_right(sexp)
      sexp[2]
   end

   alias :iasgn_get_var :lasgn_get_var
   alias :cvdecl_get_var :lasgn_get_var
   
   alias :iasgn_get_right :lasgn_get_right
   alias :cvdecl_get_right :lasgn_get_right

   alias :return_get_right :lasgn_get_var
   
   def call_get_object(sexp)
      sexp[1]
   end

   def call_get_method(sexp)
      sexp[2]
   end

   def defn_get_args(sexp)
      sexp[2].drop(1)
   end

end
