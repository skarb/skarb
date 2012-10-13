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
  # A module handling translation of classes defined in the standard library in
  # C. This module should be included in the Translator::Class module in order
  # to provide set_parent. FIXME: isn't this in fact a bad practice?
  module StdLibClasses
    # Returns true if the class definition begins with a call to
    # defined_in_stdlib method. The sexp is checked for a following structure:
    #   s(:class, :ClassName, s(:const, :Parent),
    #     s(:scope,
    #       s(:block,
    #         s(:call, nil, :defined_in_stdlib, s(:arglist)), ...
    def declared_as_defined_in_stdlib?(sexp)
      begin
        call = sexp[3][1][1]
        call[0] == :call and call[1].nil? and call[2] = :defined_in_stdlib
      rescue NoMethodError
        false
      end
    end

    # Adds an stdlib class declared in a given sexp to the symbol table.
    def load_stdlib_class(sexp)
      raise 'Not an stdlib class' unless declared_as_defined_in_stdlib? sexp
      @symbol_table.in_class sexp[1] do
        @symbol_table.class_defined_in_stdlib
        if sexp[3][1].include? s(:call, nil, :atomic_alloc, s(:arglist))
           @symbol_table.class_table[:atomic_alloc] = true
        end
        set_parent sexp if sexp[2]
        load_instance_variables sexp
        load_methods sexp
      end
    end

    # Returns the name of special init macro for a given class.
    def std_init_name(class_name)
      "#{class_name}__INIT".to_sym
    end

    private

    # Puts all referenced instance variables in the symbol_table.
    def load_instance_variables(sexp)
      sexp[3][1].rest.select { |child| child.first == :ivar } .each do |ivar|
        translate_generic_sexp ivar
      end
    end

    # Loads all methods declared in a stdlib class declaration and puts them in
    # the symbol table.sugin load_methods.
    def load_methods(sexp)
      sexp[3][1].rest.select { |child| child.first == :defn } .each do |defn|
        if not stdlib_method? defn
          raise "#{@symbol_table.cclass}.#{defn[1]} isn't a stdlib method"
        end
        mdefn = defn.clone
        mdefn[1] = escape_name mdefn[1]
        @symbol_table.add_function mdefn[1],
            s(:stdlib_defn,
              fun_name(mdefn), mdefn[2]).with_value_type(returned_type mdefn)
      end
    end

    # Returns true if the method body begins with a call to a defined_as
    # function and the first argument is a symbol.
    def stdlib_method?(defn)
      call = defn[3][1][1]
      call.first == :call and call[1].nil? and call[2] == :defined_as and
      (arg = call[3][1])[0] == :lit and arg[1].is_a? Symbol
    end

    # A symbol being the first argument of a first method call in the method
    # body. It is assumed that stdlib_method? would return true for the defn
    # sexp passed to this function.
    def fun_name(defn)
      # The ultimate masterpiece of illegible code.
      defn[3][1][1][3][1][1]
    end

    # Passes the argument to single_returned_type. If a nil is returned it calls
    # conditional_returned_types with the same argument.
    def returned_type(defn)
      single_returned_type(defn) or conditional_returned_types(defn)
    end

    # Looks up a call to 'returns' which defines the returned type. If it's
    # present it returns the specified type. Otherwise returns nil.
    def single_returned_type(defn)
      returns = defn[3][1].rest.select do |child|
        child[0..2] == s(:call, nil, :returns)
      end
      if returns.count > 1
        raise 'Invalid stdlib class method definition: ' +
          "#{@symbol_table.cclass}.#{defn[1]}"
      elsif returns.count == 1
        returns[0][3][1][1]
      end
    end

    # Looks up all calls to 'returned_if' which define the returned type
    # depending on the arguments' types. If any 'returned_if's are present a
    # hash assigning strings of arguments' types joined with an underscore to a
    # respective returned type is returned. Otherwise it returns nil.
    def conditional_returned_types(defn)
      returns = defn[3][1].rest.select do |child|
        child[0] == :call and child[2] == :returned_if
      end
      if returns.any?
        returns.reduce({}) do |hash,rule|
          hash.merge({rule[3].rest.map { |arg| arg[1].to_s } .join('_') =>
                     rule[1][1]})
        end
      end
    end
  end
end
