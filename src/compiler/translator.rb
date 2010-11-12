require 'sexp_processor'

# Responsible for transforming a Ruby AST to its C equivalent.
# It performs tree traversal by recursive execution of functions
# corresponding to certain nodes types. Each of these functions do
# the following:
# 1. Modifies symbol table
# 2. Returns translated subtree which is valid C AST or nil
# 3. Returns attributes dictionary for the given node
# Final C AST is composed depending on symbol table and subtrees 
# returned by subsequent functions.
class Translator

  # Symbol table is a dictionary consisting of pairs:
  # "symbol" - "attributes".
  # "attributes" is another dictionary consisting of entries:
  # "attribute name" - "attribute value"
  #
  # Symbol tables are nested in each other:
  # Classes --> Functions --> Local variables
  class SymbolTable < Hash
    
  end

  # Analyses a given Ruby AST tree and returns a C AST. Both the argument and
  # the returned value are Sexps from the sexp_processor gem.
  def translate(sexp)
    c_sexp = translate_generic_sexp sexp
    if c_sexp.is_empty_block?
      main_function(s(:return, c_sexp.value))
    else
      main_function(*c_sexp, s(:return, c_sexp.value))
    end
  end

  private

  # Nearly all Ruby statements have a value. It has to be stored in a variable
  # after being translated to C. We need to know what is the name of that
  # variable. Hence we add an attribute to Sexp.
  class ::Sexp
    # A C sexp (a literal or a variable) which stores the value of the sexp
    # after evaluation.
    attr_accessor :value

    # Syntactic sugar. Sets the value and returns self.
    def with_value(value)
      @value = value
      self
    end

    # True if self == s(:block)
    def is_empty_block?
      first == :block and count == 1
    end
  end

  # Wraps a given body with a 'main' function. The body is expected to be a
  # collection of Sexp instances.
  def main_function(*body)
    args = s(:abstract_args,
             s(:decl, :int, :argc),
             s(:decl, :'char**', :args))
    s(:defn, :int, :main, args, s(:block, *body))
  end

  # Calls one of translate_* methods depending on the given sexp's type.
  def translate_generic_sexp(sexp)
    send "translate_#{sexp[0]}", sexp
  end

  # Translates a literal numeric to an empty block with a value equal to a :lit
  # sexp equal to the given literal.
  def translate_lit(sexp)
    s(:block).with_value sexp
  end
end
