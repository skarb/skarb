require 'sexp_processor'

StdlibGraphs = [
   s(:function, :Object_to__s,
     s(:return, :s)),

   s(:function, :Object_puts, s(:args, :p1),
     s(:return, :s)),
  
   s(:function, :Object_rand,
     s(:return, :s)),
     
   s(:function, :Object__EQ__EQ_,
     s(:return, :s))
]
