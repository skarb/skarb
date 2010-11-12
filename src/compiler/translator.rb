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
    nil
    #sexp
  end
end
