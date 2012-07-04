require 'sexp_processor'

StdlibGraphs = [
   s(:function, :Object_to__s,
     s(:return, :s)),

   s(:function, :Object_puts, s(:args, :p1),
     s(:return, :s)),
  
   s(:function, :Object_rand,
     s(:return, :s)),
     
   s(:function, :Object__EQ__EQ_,
     s(:return, :s)),

   s(:function, :Fixnum__PLUS_, s(:args, :p1),
     s(:return, :s)),
  
   s(:function, :Fixnum__MINUS_, s(:args, :p1),
     s(:return, :s)),

   s(:function, :Fixnum__MUL_, s(:args, :p1),
     s(:return, :s)),
  
   s(:function, :Fixnum__DIV_, s(:args, :p1),
     s(:return, :s)),
  
   s(:function, :Fixnum__MINUS_AMP,
     s(:return, :s)),
  
   s(:function, :Fixnum__EQ__EQ_, s(:args, :p1),
     s(:return, :s)),

   s(:function, :Fixnum__LT_, s(:args, :p1),
     s(:return, :s)),
  
   s(:function, :Fixnum__GT_, s(:args, :p1),
     s(:return, :s)),

   s(:function, :Fixnum_to__s,
     s(:return, :s)),
  
   s(:function, :Fixnum_zero_QMARK,
     s(:return, :s)),
  
   s(:function, :Fixnum_times, s(:args, :p1),
     s(:return, :s)),
  
   s(:function, :Fixnum_upto, s(:args, :p1),
     s(:return, :s)),

   s(:function, :Float__PLUS_, s(:args, :p1),
     s(:return, :s)),
   
   s(:function, :Float__MINUS_, s(:args, :p1),
     s(:return, :s)),
   
   s(:function, :Float__MINUS_AMP, 
     s(:return, :s)),
   
   s(:function, :Float__MUL_, s(:args, :p1),
     s(:return, :s)),
   
   s(:function, :Float__DIV_, s(:args, :p1),
     s(:return, :s)),
   
   s(:function, :Float__EQ__EQ_, s(:args, :p1),
     s(:return, :s)),
   
   s(:function, :Float__LT_, s(:args, :p1),
     s(:return, :s)),
   
   s(:function, :Float__GT_, s(:args, :p1),
     s(:return, :s)),
   
   s(:function, :Float_to__s, 
     s(:return, :s)),
   
   s(:function, :Float_zero_QMARK, 
     s(:return, :s)),
   
   s(:function, :Float_floor,
     s(:return, :s)),

   s(:function, :String__PLUS_, s(:args, :p1),
     s(:return, :s)),
   
   s(:function, :String__MUL_, s(:args, :p1),
     s(:return, :s)),
   
   s(:function, :String_length, 
     s(:return, :s)),
   
   s(:function, :String_to__s, 
     s(:return, :self)),
   
   s(:function, :String_to__i,
     s(:return, :s)),

   s(:function, :String_to__f,
     s(:return, :s)),

   s(:function, :String__INDEX_,
     s(:return, :s)),
   
   s(:function, :String_empty__QMARK__,
     s(:return, :s)),
   
   s(:function, :String__EQ__EQ_,
     s(:return, :s)),
   
   s(:function, :Nil_to__s,
     s(:return, :s)),

   s(:function, :Array__INDEX_, s(:args, :p1),
     s(:return, :"self_[]")),

   s(:function, :Array__INDEX__EQ_, s(:args, :p1),
     s(:return, :self),
     s(:graph_edges,
       s(:self, :"self_[]"),
       s(:"self_[]", :p1))),

   s(:function, :Array_pop, 
     s(:return, :"self_[]")),

   s(:function, :Array_push, s(:args, :p1),
     s(:return, :self),
     s(:graph_edges,
       s(:self, :"self_[]"),
       s(:"self_[]", :p1))),
   
   s(:function, :Array_shift, 
     s(:return, :"self_[]")),

   s(:function, :Array_unshift, s(:args, :p1),
     s(:return, :self),
     s(:graph_edges,
       s(:self, :"self_[]"),
       s(:"self_[]", :p1))),

   s(:function, :Array_delete, s(:args, :p1),
     s(:return, :p1)),
   
   s(:function, :Array__EQ__EQ_, s(:args, :p1),
     s(:return, :s)),
   
   s(:function, :Array_length,
     s(:return, :s)),
   
   s(:function, :Array_join, s(:args, :p1),
     s(:return, :s)),
   
   s(:function, :Array_map, s(:args, :p1),
     s(:return, :s)),
   
   s(:function, :Hash__INDEX_, s(:args, :p1),
     s(:return, :"self_[]")),
   
   s(:function, :Hash__INDEX__EQ_, s(:args, :p1, :p2),
     s(:return, :p2),
     s(:graph_edges,
       s(:self, :"self_[]"),
       s(:"self_[]", :p1),
       s(:"self_[]", :p2))),

   s(:function, :Hash_delete, s(:args, :p1),
     s(:return, :"self_[]")),
   
   s(:function, :Hash_keys, 
     s(:return, :s)),

   s(:function, :True_to__s, 
     s(:return, :s)),
   
   s(:function, :False_to__s, 
     s(:return, :s))
]
