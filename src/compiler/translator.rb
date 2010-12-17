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
require 'translator/constants'

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
    [:Object, MainObject].each {|x| @symbol_table.add_class x }
    @functions_implementations = {}
    @structures_definitions = {}
    @user_classes = [MainObject]
  end

  # Analyses a given Ruby AST tree and returns a C AST. Both the argument and
  # the returned value are Sexps from the sexp_processor gem. AST is splitted
  # in 4 sections: structs, prototypes, functions, global variables + main
  def translate(sexp)
    main_block = translate_generic_sexp(sexp)
    main = main_function CallInitialize, AllocateSelf, *lvars_declarations,
      main_block, ReturnZero
    # If there are any functions other than main they have to be included in
    # the output along with their prototypes.
    @user_classes.each { |x| generate_class_structure x }
    implement_generic_methods
    protos = generate_prototypes
    [s(:file, *@structures_definitions.values), s(:file, *protos),
      s(:file, *@functions_implementations.values), s(:file, main)]
  end

  attr_accessor :symbol_table

  private

  include Helpers
  include Functions
  include FlowControl
  include LocalVariables
  include InstanceVariables
  include TypeChecks
  include Classes
  include Constants

  # Name of modified instance of Object class containing main program
  MainObject = :M_Object

  # A sexp representing 'return 0;'
  ReturnZero = s(:return, s(:lit, 0))

  # A sexp corresponding to allocation of global variables structure
  AllocateSelf = s(:stmts, s(:decl, :'M_Object', :self_s),
                 s(:asgn, s(:decl, :'Object*', :self),
                   s(:cast, :'Object*', s(:var, :'&self_s'))))

  # A call to the initialize function
  CallInitialize = s(:call, :initialize, s(:args))

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
    # Is there a public or a private method translating such a sexp?
    if respond_to? (method_name = "translate_#{sexp[0]}".to_sym), true
      send method_name, sexp
    else
      die 'Input contains unsupported Ruby instructions. Aborting.'
    end
  end

  # Translates a block of expressions by translating all of them and returning a
  # stmts sexp with a value of the last translated element.
  def translate_block(sexp)
    sexps = sexp.drop(1).map { |s| translate_generic_sexp s }
    filtered_stmts(*sexps).with_value_of sexps.last
  end

  alias :translate_scope :translate_block

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
    filtered_stmts(child).with_value_sexp(
      s(:call, :not, s(:args, child.value_sexp)))
  end

  # Translates a 'nil'.
  def translate_nil(sexp)
    s(:stmts).with_value s(:var, :nil), :NilClass
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

  # Implements all methods for generic (unknown) arguments unless they
  # are already implemented.
  def implement_generic_methods
    @symbol_table.each do |cname, chash|
      if chash.has_key?(:functions_def)
        methods_init = chash[:functions_def].each.map do |fname, fdef|
          if fdef[0] != :stdlib_defn # Ignore stdlib functions
            types = fdef[2].rest.map { nil }
            impl_name = mangle(fname, cname, types)
            unless function_implemented? impl_name
              @symbol_table.in_class cname do
                implement_function impl_name, fdef, types
              end
            end
          end
        end
      end
    end
  end
end
