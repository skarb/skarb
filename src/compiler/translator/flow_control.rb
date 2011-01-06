class Translator
  # A module consisting of functions which handle translation of nodes related
  # to flow control, such as conditionals, loops etc.
  module FlowControl
    def translate_if(sexp)
      # Rewrite the sexp if it's an unless expression.
      if sexp[2].nil?
        sexp = s(:if, s(:not, sexp[1]), sexp[3], nil)
      end
      return translate_if_else sexp if sexp[3]
      var = next_var_name
      cond = translate_generic_sexp sexp[1]
      if_true = @symbol_table.in_block { translate_generic_sexp sexp[2] }
      filtered_stmts(
        s(:decl, :'Object*', var),
        cond,
        s(:if, boolean_value(cond.value_sexp),
          filtered_block(if_true, s(:asgn, s(:var, var), if_true.value_sexp)))
      ).with_value s(:var, var), if_true.value_type
    end

    # TODO: DRY, translate_if is almost identical.
    def translate_if_else(sexp)
      var = next_var_name
      cond = translate_generic_sexp sexp[1]
      if_true = @symbol_table.in_block { translate_generic_sexp sexp[2] }
      if_false = @symbol_table.in_block { translate_generic_sexp sexp[3] }
      return_type = determine_if_else_types if_true.value_type, if_false.value_type
      filtered_stmts(
        s(:decl, :'Object*', var),
        cond,
        s(:if,
          boolean_value(cond.value_sexp),
          filtered_block(if_true, s(:asgn, s(:var, var), if_true.value_sexp)),
          filtered_block(if_false, s(:asgn, s(:var, var), if_false.value_sexp)))
      ).with_value s(:var, var), return_type
    end
  end

  # Translates a while loop. Such loop in Ruby doesn't return a value so we do
  # not set the value_sexp attribute.
  def translate_while(sexp)
    cond = translate_generic_sexp sexp[1]
    body1 = body2 = s()
    @symbol_table.in_block do
      body1 = translate_generic_sexp sexp[2]
      body2 = @symbol_table.in_block { translate_generic_sexp sexp[2] }
    end
    filtered_stmts(
      cond,
      s(:while, boolean_value(cond.value_sexp),
        filtered_block(
          body1,
          s(:while, s(:lit, 1),
             filtered_block(
             cond,
             s(:if, s(:l_unary_oper, :!, boolean_value(cond.value_sexp)), s(:break)),
             body2)),
          s(:break))))
  end

  # Translates an until loop. Such loop in Ruby doesn't return a value so we do
  # not set the value_sexp attribute.
  def translate_until(sexp)
    cond = translate_generic_sexp sexp[1]
    body = @symbol_table.in_block { translate_generic_sexp sexp[2] }
    s(:while, s(:lit, 1),
      filtered_block(cond,
                     s(:if, boolean_value(cond.value_sexp), s(:break)),
                     body))
  end

  # A trivial break translation.
  def translate_break(sexp)
    s(:break)
  end

  # We cannot use C's switch if we want to implement the original Ruby's case
  # behaviour. Ruby's case can make nontrivial comparisons (such as strings
  # comparisons). As a result case has to be translated to a if-elsif-else block
  # with equality comparisons.
  def translate_case(sexp)
    when_sexps = sexp.drop(1).find_all { |s| s.first == :when }
    top_if = sexp.last unless sexp.last.first == :when
    while when_sexps.any?
      when_sexp = when_sexps.last[1][1]
      then_sexp = when_sexps.pop[2]
      top_if = s(:if, s(:call, sexp[1], :==, s(:args, when_sexp)),
                 then_sexp, top_if)
    end
    translate_if top_if
  end

  private

  # Analyzes return types of both blocks and determines return type of
  # whole if-else expression. If return types of both branches are identical
  # or one branch opens recursion, return type of whole if is known.
  def determine_if_else_types(type1, type2)
    return type2 if type1 == :recur
    return type1 if type2 == :recur
    return type1 if type1 == type2
    return nil if type1 != type2
  end

  def translate_return(sexp)
    if sexp.count == 1
      ret = s().with_value_sexp s(:var, :nil)
      @symbol_table.returned_type = nil
    else
      ret = translate_generic_sexp sexp[1]
      @symbol_table.returned_type = ret.value_type
    end
    filtered_stmts ret, s(:return, ret.value_sexp)
  end
end
