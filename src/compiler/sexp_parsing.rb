require 'sexp_processor'

# Functions that help extracting specific elements from sexps.
module SexpParsing
  
   def lasgn_get_var(sexp)
      sexp[1]
   end

   def lasgn_get_right(sexp)
      sexp[2]
   end

   def call_get_object(sexp)
      sexp[1]
   end

   def call_get_method(sexp)
      sexp[2]
   end

end
