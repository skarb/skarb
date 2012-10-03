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

##################################################################################
# (C) 2010-2012 Jan Stępień, Julian Zubek
# 
# This file is a part of Skarb -- Ruby to C compiler.
# 
# Skarb is free software: you can redistribute it and/or modify it under the terms
# of the GNU Lesser General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later
# version.
# 
# Skarb is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
# PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
# 
# You should have received a copy of the GNU Lesser General Public License along
# with Skarb. If not, see <http://www.gnu.org/licenses/>.
# 
##################################################################################
