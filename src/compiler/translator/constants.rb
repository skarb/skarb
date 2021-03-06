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

class Translator
   # A module consisting of functions which handle translation of constants such
   # as strings, literals and constant symbols.
   module Constants
      # Returns empty sexp with value of an constants
      def translate_const(sexp)
         if @symbol_table.has_key? sexp[1]
            value = @symbol_table.value_of sexp[1]
            s().with_value(value.value_sexp, value.value_type).
               with_class_type value.class_type
         else
            s().with_value(sexp[1], sexp[1]).with_class_type sexp[1]
         end
      end

      # Translates constant declaration
      def translate_cdecl(sexp)
         var_name = mangle_const_name sexp[1]
         var = s(:var, var_name)
         arg = translate_generic_sexp sexp[2]
         @symbol_table.add_constant sexp[1], s().with_value(var, arg.value_type)
         @globals[var_name] = s(:decl, :'Object*', var_name)
         filtered_stmts(arg,
                        s(:asgn, var, arg.value_sexp)).with_value(var, arg.value_type)
      end

      # Translates a literal numeric to an empty block with a value equal to a
      # :lit sexp equal to the given literal.
      def translate_lit(sexp)
         if sexp[1].floor == sexp[1]
            # It's an integer
            ctor = std_init_name(:Fixnum)
            class_name = :Fixnum
         else
            # It's a float
            ctor = std_init_name(:Float)
            class_name = :Float
         end
         var = next_var_name
         filtered_stmts(class_constructor(class_name, var),
                        s(:call, ctor, s(:args, s(:var, var), sexp))).with_value(s(:var, var), class_name)
      end

      # Translates a string literal.
      def translate_str(sexp)
         sexp = sexp.clone
         # No idea why does it need that many backslashes.
         sexp[1] = sexp[1].gsub('\\', '\\\\\\').gsub("\n", "\\n")

         var = next_var_name
         filtered_stmts(class_constructor(:String, var),
                        s(:call, std_init_name(:String), s(:args, s(:var, var), sexp))).with_value(s(:var, var), :String)
      end

      # Translates an array literal, such as [1, 2, "three"].
      def translate_array(sexp)
         var = next_var_name
         s = filtered_stmts(class_constructor(:Array, var),
                            s(:call, std_init_name(:Array), s(:args, s(:var, var))))

         if sexp.count > 1
            args = sexp.rest.map { |child| translate_generic_sexp child }
            s << filtered_block(*args, *args.map do |arg|
               s(:call, :Array_push, s(:args, s(:var, var), arg.value_sexp))
            end)
         end  

         s.with_value(s(:var, var), :Array)
      end

      # Translates a hash literal, such as {1 => nil, 2 => "three"}.
      def translate_hash(sexp)
         var = next_var_name
         s = filtered_stmts(class_constructor(:Hash, var),
                            s(:call, std_init_name(:Hash), s(:args, s(:var, var))))

         if sexp.count > 1
            args = sexp.rest.map { |child| translate_generic_sexp child }
            pairs = args.odd.zip args.even
            s <<  filtered_block(*args, *pairs.map do |key,val|
               s(:call, :Hash__INDEX__EQ_,
                 s(:args, s(:var, var), key.value_sexp, val.value_sexp))
            end)
         end

         s.with_value(s(:var, var), :Hash)
      end

      # Translates a 'false'.
      def translate_false(sexp)
         s(:stmts).with_value(s(:var, :false), :FalseClass)
      end

      # Translates a 'true'.
      def translate_true(sexp)
         s(:stmts).with_value(s(:var, :true), :TrueClass)
      end
   end
end
