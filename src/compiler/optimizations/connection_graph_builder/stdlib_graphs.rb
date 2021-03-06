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

   s(:function, :Object_nil__QMARK,
     s(:return, :s)),

   s(:function, :Fixnum__PLUS_, s(:args, :p1),
     s(:return, :s)),
  
   s(:function, :Fixnum__MINUS_, s(:args, :p1),
     s(:return, :s)),

   s(:function, :Fixnum__MUL_, s(:args, :p1),
     s(:return, :s)),
  
   s(:function, :Fixnum__POW_, s(:args, :p1),
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
   
   s(:function, :Array_max, 
     s(:return, :"self_[]")),

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
