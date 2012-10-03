# This file consists of extensions to existing classes.

require 'sexp_processor'

# Extending Sexp is required by the Translator. Nearly all Ruby statements have
# a value. It has to be stored in a variable after being translated to C. We
# need to know what is the name and the type of that variable. Hence we add two
# attributes to Sexp.
class ::Sexp
  # value_sexp is a C sexp (a literal, a variable or a call) which stores the
  # value of the actual sexp after evaluation. It should have been named +value+
  # but this method name is unfortunately already taken by RubyParser.
  # value_type is the type of value_sexp. It can either be an instance of a
  # Class or nil in case we cannot determine the exact type.
  # class_type is only used if value_type is Class
  attr_accessor :value_sexp, :value_type, :class_type

  # Syntactic sugar. Sets the class_type and returns self.
  def with_class_type(class_type)
    @class_type = class_type
    self
  end

  # Syntactic sugar. Sets the value_sexp and returns self.
  def with_value_sexp(value_sexp)
    @value_sexp = value_sexp
    self
  end

  # Syntactic sugar. Sets the value_type and returns self.
  def with_value_type(value_type)
    @value_type = value_type
    self
  end

  # Syntactic sugar. Sets the value_sexp, value_type and returns self.
  def with_value(sexp, type)
    @value_type = type
    @value_sexp = sexp
    self
  end

  # Syntactic sugar. Sets the value_sexp and value_type to ones of a given sexp
  # and returns self.
  def with_value_of(other_sexp)
    return if other_sexp.nil?
    @value_type = other_sexp.value_type
    @value_sexp = other_sexp.value_sexp
    self
  end

  # Recursively searches for first sexp satisfying condition given as block.
  def find_recursive(&cond)
     if yield self
        self
     else
        self.each do |se|
           if se.is_a? Sexp
              res = se.find_recursive &cond
              if res.is_a? Sexp
                 return res
              end
           end
        end
        return
     end
  end
 
  # Execute block recursively for sexp and all its children.
  def each_recursive(&block)
     yield self
     self.each do |se|
        if se.is_a? Sexp
           se.each_recursive &block
        end
     end
  end

end

# Extensions for standard Array class used by the Emitter.
class ::Array
  # Returns a slice from the middle of the array
  # - a -- index of first char of the slice
  # - b -- negative index of last char of the slice
  def middle(a=1, b=-1)
    return self[a..self.length+b-1]
  end

  # Returns fragment from supplied index to the end of the array
  def rest(index=1)
    return self[index..self.length-1] if index >= 0
    return self[0, self.length+index]
  end

  # Returns first, third and every second element of the array
  def odd
    if any?
      [self[0]] + drop(2).odd
    else
      []
    end
  end

  # Returns second, fourth and every second element of the array
  def even
    if any?
      drop(1).odd
    else
      []
    end
  end
end

# Extensions for standard Symbol class used by the Translator
class ::Symbol
   # Returns fragment from supplied index to the end of the array
  def rest(index=1)
    return (self.to_s[index..self.length-1]).to_sym if index >= 0
    return (self.to_s[0, self.length+index]).to_sym
  end

  # Returns starred symbol
  def star
    (self.to_s+'*').to_sym
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
