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
  attr_accessor :value_sexp, :value_type

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
    @value_type = other_sexp.value_type
    @value_sexp = other_sexp.value_sexp
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
