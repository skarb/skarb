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

   def call_get_args(sexp)
      sexp[3].drop(1)
   end

   def defn_get_args(sexp)
      sexp[2].drop(1)
   end

   def translated_fun_name(c_sexp)
      c_sexp.last.last[1]
   end

end
