# This file consists of extensions to existing classes.

require 'sexp_processor'

# Extending Sexp is required by the Translator. Nearly all Ruby statements have
# a value. It has to be stored in a variable after being translated to C. We
# need to know what is the name and the type of that variable. Hence we add two
# attributes to Sexp.
class ::Sexp
  # A C sexp (a literal or a variable) which stores the value of the sexp
  # after evaluation. It should have been named +value+ but this method name
  # is unfortunately already taken by RubyParser.
  attr_accessor :value_symbol, :value_types

  # Syntactic sugar. Sets the value_symbol and returns self.
  def with_value_symbol(value_symbol)
    @value_symbol = value_symbol
    self
  end

  # Syntactic sugar. Sets the value_types and returns self.
  def with_value_types(value_types)
    @value_types = value_types
    self
  end

  # Syntactic sugar. Sets the value_symbol, value_types and returns self.
  def with_value(symbol, types)
    @value_types = types
    @value_symbol = symbol
    self
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
