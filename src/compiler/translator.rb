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
    ret = s(:return, c_sexp.value_symbol)
    if c_sexp.first == :stmts
      main_function(*(c_sexp.drop 1), ret)
    else
      main_function(c_sexp, ret)
    end
  end

  private

  # Nearly all Ruby statements have a value. It has to be stored in a variable
  # after being translated to C. We need to know what is the name of that
  # variable. Hence we add an attribute to Sexp.
  class ::Sexp
    # A C sexp (a literal or a variable) which stores the value of the sexp
    # after evaluation. It should have been named +value+ but this method name
    # is unfortunately already taken by RubyParser.
    attr_accessor :value_symbol

    # Syntactic sugar. Sets the value_symbol and returns self.
    def with_value_symbol(value_symbol)
      @value_symbol = value_symbol
      self
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

  # Calls translate_generic_sexp with value_matters = true
  #def translate_generic_sexp_with_value(sexp)
  #  translate_generic_sexp sexp, true
  #end

  # Calls one of translate_* methods depending on the given sexp's type.
  def translate_generic_sexp(sexp)
    send "translate_#{sexp[0]}", sexp
  end

  # Translates a literal numeric to an empty block with a value equal to a :lit
  # sexp equal to the given literal.
  def translate_lit(sexp)
    s(:stmts).with_value_symbol sexp
  end

  def translate_if(sexp)
    var = next_var_name
    assign_to_var = lambda { |val| s(:asgn, s(:var, var), val) }
    cond = translate_generic_sexp sexp[1]
    if_true = translate_generic_sexp sexp[2]
    if_false = translate_generic_sexp sexp[3]
    filtered_stmts(
      s(:decl, :int, var),
      cond,
      s(:if,
        cond.value_symbol,
        filtered_block(if_true, assign_to_var.call(if_true.value_symbol)),
        filtered_block(if_false, assign_to_var.call(if_false.value_symbol)))
    ).with_value_symbol var
  end

  def filtered_block(*args)
    s(:block, *(filter_empty_sexps args))
  end

  def filtered_stmts(*args)
    s(:stmts, *(filter_empty_sexps args))
  end

  def filter_empty_sexps(sexps)
    sexps.delete_if { |sexp| sexp == s(:stmts) }
  end

  # Each call to this method returns a new, unique var name.
  def next_var_name
    @n ||= 0
    "var#{@n += 1}".to_sym
  end
end
