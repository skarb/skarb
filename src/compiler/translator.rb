require 'sexp_processor'
require 'helpers'
require 'extensions'
require 'translator/symbol_table'
require 'translator/functions'
require 'translator/flow_control'
require 'translator/local_variables'
require 'translator/instance_variables'
require 'translator/type_checks'
require 'translator/classes'

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
  def initialize
    @symbol_table = SymbolTable.new
    [:Object, :Fixnum, :Float].each {|x| @symbol_table.add_class x }
    @symbol_table.cclass = :Object
    @symbol_table.cfunction = :_main
    @functions_definitions = {}
    @functions_implementations = {}
    @structures_definitions = {}
    @user_classes = []
  end

  # Analyses a given Ruby AST tree and returns a C AST. Both the argument and
  # the returned value are Sexps from the sexp_processor gem.
  def translate(sexp)
    main = main_function translate_generic_sexp(sexp), ReturnZero
    # If there are any functions other than main they have to be included in
    # the output along with their prototypes.
    @user_classes.each { |x| generate_class_structure x }
    protos = @functions_implementations.values.map do |fun|
      s(:prototype, *fun[1,3])
    end
    includes = Headers.map { |h| s(:include, h) }
    s(:file, *includes, *@structures_definitions.values,
      *protos, *@functions_implementations.values, main)
  end

  private

  include Helpers
  include Functions
  include FlowControl
  include LocalVariables
  include InstanceVariables
  include TypeChecks
  include Classes

  # A sexp representing 'return 0;'
  ReturnZero = s(:return, s(:lit, 0))

  # A list of headers to be included.
  Headers = %w/<stdio.h> <rubyc.h>/

  # Wraps a given body with a 'main' function. The body is expected to be a
  # collection of Sexp instances.
  def main_function(*body)
    args = s(:abstract_args,
             s(:decl, :int, :argc),
             s(:decl, :'char**', :args))
    s(:defn, :int, :main, args, filtered_block(*body))
  end

  # Calls one of translate_* methods depending on the given sexp's type.
  def translate_generic_sexp(sexp)
    begin
      send "translate_#{sexp[0]}", sexp
    rescue NoMethodError
      die 'Input contains unsupported Ruby instructions. Aborting.'
    end
  end

  # Translates a literal numeric to an empty block with a value equal to a :lit
  # sexp equal to the given literal.
  def translate_lit(sexp)
    if sexp[1].floor == sexp[1]
      # It's an integer
      ctor = :Fixnum_new
    else
      # It's a float
      ctor = :Float_new
    end
    s(:stmts).with_value(s(:call, ctor, s(:args, sexp)), sexp[1].class)
  end

  # Translates a block of expressions by translating all of them and returning a
  # stmts sexp with a value of the last translated element.
  def translate_block(sexp)
    sexps = sexp.drop(1).map { |s| translate_generic_sexp s }
    filtered_stmts(*sexps).with_value_sexp sexps.last.value_sexp
  end

  # Returns a block sexp with all stmts sexps expanded.
  def filtered_block(*args)
    s(:block, *expand_stmts(args))
  end

  # Returns a stmts sexp with all stmts sexps expanded.
  def filtered_stmts(*args)
    s(:stmts, *expand_stmts(args))
  end

  # Translates a 'not' or a '!'.
  def translate_not(sexp)
    child = translate_generic_sexp sexp[1]
    filtered_stmts(child).with_value_sexp s(:l_unary_oper, :!,
                                              boolean_value(child.value_sexp))
  end

  # Returns an array of sexps with all stmts sexps expanded.
  def expand_stmts(sexps)
    # This array of sexps will be the content of the returned block.
    expanded_sexps = []
    sexps.each do |sexp|
      if sexp.first == :stmts
        # If it's a stmts take all its children and add them to the output
        expanded_sexps += sexp.drop 1
      elsif sexp.empty?
        # Do nothing
      else
        # Otherwise add the whole sexp to the output
        expanded_sexps << sexp
      end
    end
    expanded_sexps
  end

  # Each call to this method returns a new, unique var name.
  def next_var_name
    @next_id ||= 0
    "var#{@next_id += 1}".to_sym
  end

  # Returns a sexp representing a call to the boolean_value function with a
  # given value.
  def boolean_value(value)
    s(:call, :boolean_value, s(:args,
                               s(:call, :TO_OBJECT, s(:args, value))))
  end
end
