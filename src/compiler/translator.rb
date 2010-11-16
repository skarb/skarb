require 'sexp_processor'
require 'helpers'
require 'extensions'
require 'translator/symbol_table'

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
    @symbol_table.cclass = Object
    @symbol_table.cfunction = :_main
  end

  # Analyses a given Ruby AST tree and returns a C AST. Both the argument and
  # the returned value are Sexps from the sexp_processor gem.
  def translate(sexp)
    main_function translate_generic_sexp(sexp), ReturnZero
  end

  # For debugging purposes only
  def _translate_generic_debug(sexp)
    translate_generic_sexp sexp
  end

  private

  include Helpers

  # A sexp representing 'return 0;'
  ReturnZero = s(:return, s(:lit, 0))

  # Wraps a given body with a 'main' function. The body is expected to be a
  # collection of Sexp instances.
  def main_function(*body)
    args = s(:abstract_args,
             s(:decl, :int, :argc),
             s(:decl, :'char**', :args))
    s(:defn, :int, :main, args, filtered_block(*body))
  end

  # Calls translate_generic_sexp with value_matters = true
  #def translate_generic_sexp_with_value(sexp)
  #  translate_generic_sexp sexp, true
  #end

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
    s(:stmts).with_value(sexp, [sexp[1].class])
  end

  # TODO: Translation
  def translate_lasgn(sexp)
    arg = translate_generic_sexp(sexp[2])
    @symbol_table.add_lvar sexp[1] unless @symbol_table.lvars_table.has_key? sexp[1]
    @symbol_table.lvars_table[sexp[1]][:types] = arg.value_types
    s().with_value(arg.value_symbol, arg.value_types)
  end

  # TODO: Translation
  def translate_lvar(sexp)
    s(:stmts).with_value(s(:var, sexp[1]),
                         @symbol_table.lvars_table[sexp[1]][:types])
  end

  def translate_if(sexp)
    # Rewrite the sexp if it's an unless expression.
    sexp = s(:if, s(:not, sexp[1]), sexp[3], nil) if sexp[2].nil?
    return translate_if_else sexp if sexp[3]
    var = next_var_name
    assign_to_var = lambda { |val| s(:asgn, s(:var, var), val) }
    cond = translate_generic_sexp sexp[1]
    if_true = translate_generic_sexp sexp[2]
    filtered_stmts(
      s(:decl, :int, var),
      cond,
      s(:if, cond.value_symbol,
        filtered_block(if_true, assign_to_var.call(if_true.value_symbol)))
    ).with_value_symbol s(:var, var)
  end

  # TODO: DRY, translate_if is almost identical.
  def translate_if_else(sexp)
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
    ).with_value_symbol s(:var, var)
  end

  # Returns a block sexp with all stmts sexps' children extracted.
  def filtered_block(*args)
    # This array of sexp will be the content of the returned block.
    filtered_args = []
    args.each do |sexp|
      if sexp.first == :stmts
        # If it's a stmts take all its children and add them to the output
        filtered_args += sexp.drop 1
      else
        # Otherwise add the whole sexp to the output
        filtered_args << sexp
      end
    end
    s(:block, *filtered_args)
  end

  # Returns a stmts sexp with all empty statements sexps removed.
  def filtered_stmts(*args)
    s(:stmts, *(filter_empty_sexps args))
  end

  # Translates a while loop. Such loop in Ruby doesn't return a value so we do
  # not set the value_symbol attribute.
  def translate_while(sexp)
    cond = translate_generic_sexp sexp[1]
    body = translate_generic_sexp sexp[2]
    filtered_stmts(cond,
                   s(:while,
                     cond.value_symbol,
                     filtered_block(body)))
  end

  # Translates an until loop. Such loop in Ruby doesn't return a value so we do
  # not set the value_symbol attribute.
  def translate_until(sexp)
    cond = translate_generic_sexp sexp[1]
    body = translate_generic_sexp sexp[2]
    filtered_stmts(cond,
                   s(:while, s(:l_unary_oper, :!, cond.value_symbol),
                     filtered_block(body)))
  end

  # Translates a 'not' or a '!'.
  def translate_not(sexp)
    child = translate_generic_sexp sexp[1]
    filtered_stmts(child).with_value_symbol s(:l_unary_oper,
                                              :!, child.value_symbol)
  end

  # We cannot use C's switch if we want to implement the original Ruby's case
  # behaviour. Ruby's case can make nontrivial comparisons (such as strings
  # comparisons). As a result case has to be translated to a if-elsif-else block
  # with equality comparisons.
  # FIXME: we can't call methods yet so it's pretty useless at the moment.
  # Once we'll have objects and Object#== instead of completely incorrect
  #   s(:if, when_sexp, ...
  # we'll have here something like
  #   s(:if, s(:call, value, :==, s(:args, when_sexp)), ...
  def translate_case(sexp)
    value = translate_generic_sexp sexp[1]
    when_sexps = sexp.drop(1).find_all { |s| s.first == :when }
    top_if = sexp.last unless sexp.last.first == :when
    while when_sexps.any?
      when_sexp = when_sexps.last[1][1]
      then_sexp = when_sexps.pop[2]
      # FIXME: it's not the way 'case' works.
      top_if = s(:if, when_sexp, then_sexp, top_if)
    end
    translate_if top_if
  end

  # Translates a call to the Kernel#puts method. All other calls cause an error.
  def translate_call(sexp)
    raise 'Kernel#puts is the only supported method' if sexp[1,2] != s(nil, :puts)
    value = sexp[3][1]
    raise 'Only integers can be printed' if value[0] != :lit
    var = next_var_name
    s(:stmts,
      s(:decl, :int, var),
      s(:asgn,
        s(:var, var),
        s(:call, :printf, s(:args, s(:str, '%i\n'), s(:lit, value[1]))))
     ).with_value_symbol s(:var, var)
  end

  # Returns an array of sexps with all empty statements sexps, that is s(:stmts)
  # deleted.
  def filter_empty_sexps(sexps)
    sexps.delete_if { |sexp| sexp == s(:stmts) }
  end

  # Each call to this method returns a new, unique var name.
  def next_var_name
    @next_id ||= 0
    "var#{@next_id += 1}".to_sym
  end
end
