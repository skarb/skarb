class Translator
  # A module consisting of functions which handle translation of nodes related
  # to flow control, such as conditionals, loops etc.
  module FlowControl
    def translate_if(sexp)
      # Rewrite the sexp if it's an unless expression.
      boolean_value_applied = false
      if sexp[2].nil?
        sexp = s(:if, s(:not, sexp[1]), sexp[3], nil)
        boolean_value_applied = true
      end
      return translate_if_else sexp if sexp[3]
      var = next_var_name
      cond = translate_generic_sexp sexp[1]
      if_true = translate_generic_sexp sexp[2]
      filtered_stmts(
        s(:decl, 'Fixnum*', var),
        cond,
        s(:if, (boolean_value_applied ? cond.value_symbol: boolean_value(cond.value_symbol)),
          filtered_block(if_true, s(:asgn, s(:var, var), if_true.value_symbol)))
      ).with_value_symbol s(:var, var)
    end

    # TODO: DRY, translate_if is almost identical.
    def translate_if_else(sexp)
      var = next_var_name
      cond = translate_generic_sexp sexp[1]
      if_true = translate_generic_sexp sexp[2]
      if_false = translate_generic_sexp sexp[3]
      filtered_stmts(
        s(:decl, 'Fixnum*', var),
        cond,
        s(:if,
          boolean_value(cond.value_symbol),
          filtered_block(if_true, s(:asgn, s(:var, var), if_true.value_symbol)),
          filtered_block(if_false, s(:asgn, s(:var, var), if_false.value_symbol)))
      ).with_value_symbol s(:var, var)
    end
  end

  # Translates a while loop. Such loop in Ruby doesn't return a value so we do
  # not set the value_symbol attribute.
  def translate_while(sexp)
    cond = translate_generic_sexp sexp[1]
    body = translate_generic_sexp sexp[2]
    filtered_stmts(cond,
                   s(:while,
                     boolean_value(cond.value_symbol),
                     filtered_block(body)))
  end

  # Translates an until loop. Such loop in Ruby doesn't return a value so we do
  # not set the value_symbol attribute.
  def translate_until(sexp)
    cond = translate_generic_sexp sexp[1]
    body = translate_generic_sexp sexp[2]
    filtered_stmts(cond,
                   s(:while,
                     s(:l_unary_oper, :!, boolean_value(cond.value_symbol)),
                     filtered_block(body)))
  end

  # A trivial break translation.
  def translate_break(sexp)
    s(:break)
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
end
