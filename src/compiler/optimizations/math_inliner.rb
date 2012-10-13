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
require 'extensions'

# Class responsible for inlining arithmetic expressions.
class MathInliner 

   class NotInlineableError < Exception
   end

   include Mangling
   include Translator::Classes

   def initialize(translator)
      @translator = translator
      @symbol_table = translator.symbol_table
      @translator.subscribe(:call_translated, self.method(:call_translated))
   end

   # Translator event handler
   def call_translated(event)
      if inlineable? event.original_sexp
         optimized_sexp = translate(event.original_sexp)
         return if optimized_sexp.nil?
         event.translated_sexp.clear
         optimized_sexp.each do |x|
            event.translated_sexp << x
         end
         event.translated_sexp.with_value_of(optimized_sexp)
      end
   end

   # Attempts to translate sexp as an arithmetic expression containing operators,
   # local variables and literals.
   def translate(sexp)
      t = translate_generic_sexp(sexp)
      var = @translator.next_var_name
      ctor = std_init_name(t.value_type)
      add_border_mark(sexp)
      s(:stmts, class_constructor(t.value_type, var),
        s(:call, ctor,
          s(:args, s(:var, var), t.value_sexp))).with_value(s(:var, var), t.value_type)
   rescue NotInlineableError
      nil
   end

   # Returns true if MathInliner can inline a given call sexp.
   def inlineable? sexp
      InlinedOperators.include? sexp[2]
   end

   protected

   InlinedOperators = [:+, :-, :*, :/]

   # Calls one of translate_* methods depending on the given sexp's type.
   def translate_generic_sexp(sexp)
      # Is there a public or a private method translating such a sexp?
      if respond_to? (method_name = "translate_#{sexp[0]}".to_sym), true
         remove_border_mark(sexp)
         send(method_name, sexp)
      else
         raise NotInlineableError 
      end
   end

   # Returns value extracted from Fixnum or Float object pointed by local variable.
   # Throws NotInlineableError if variable is of different type.
   def translate_lvar(sexp)
      raise NotInlineableError unless @symbol_table.has_lvar? sexp[1]
      var_type = @symbol_table.get_lvar_type sexp[1] 
      raise NotInlineableError unless [:Fixnum, :Float].include? var_type 
      var_name = mangle_lvar_name sexp[1]
      s().with_value(s(:binary_oper,
                       :'->', s(:cast, var_type.to_s.to_sym.star,
                                s(:var, var_name)), s(:var, :val)), var_type)
   end

   # Returns literal value if it is a number.
   # Throws NotInlineableError otherwise.
   def translate_lit(sexp)
      var_type = sexp[1].class.to_s.to_sym
      raise NotInlineableError unless [:Fixnum, :Float].include? var_type 
      s().with_value(s(:lit, sexp[1]), var_type)
   end

   # Translates calls corresponding to arithmetic operators.
   def translate_call(sexp)
      raise NotInlineableError unless inlineable? sexp
      arg1 = translate_generic_sexp sexp[1]
      arg2 = translate_generic_sexp sexp[3][1]
      res_type = ([arg1.value_type, arg2.value_type].include? :Float) ? :Float : :Fixnum
      s().with_value(s(:binary_oper,
                       sexp[2], arg1.value_sexp, arg2.value_sexp), res_type)
   end

   # Adds meta information to the sexp informing that it is a border of inlined
   # expression.
   def add_border_mark(sexp)
      def sexp.inline_border?
         true
      end 
   end
   
   # Removes meta information from the sexp informing that it is a border of inlined
   # expression.
   def remove_border_mark(sexp)
      def sexp.inline_border?
         false
      end 
   end

end
