# Copyright (c) 2010-2012 Jan Stępień, Julian Zubek
#
# This file is a part of Skarb -- a Ruby to C compiler.
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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
  # not set the value_sexp attribute. It is translated as two nested while loops:
  # the outer loop contains translated body, inner loop and break statement, the
  # inner loop translated body. This way translated loop is immune to type of
  # variable changing during the first execution of the body and it is possible
  # to exit with a single break statement. 
  def translate_while(sexp)
    cond1 = translate_generic_sexp(sexp[1])
    body1 = body2 = cond2 = s()
    @symbol_table.in_block do
      body1 = translate_generic_sexp(sexp[2])
      body2 = @symbol_table.in_block(true) do
         translate_generic_sexp(sexp[2])
      end
      cond2 = @symbol_table.in_block(true) do
         translate_generic_sexp(sexp[1])
      end
    end
    filtered_stmts(
      cond1,
      s(:while, boolean_value(cond1.value_sexp),
        filtered_block(
          body1,
          s(:while, s(:lit, 1),
             filtered_block(
             cond2,
             s(:if, s(:l_unary_oper, :'!', boolean_value(cond2.value_sexp)), s(:break)),
             body2)),
          s(:break))))
  end

  # Translates an until loop. Such loop in Ruby doesn't return a value so we do
  # not set the value_sexp attribute. It is translated as two nested while loops:
  # the outer loop contains translated body, inner loop and break statement, the
  # inner loop translated body. This way translated loop is immune to type of
  # variable changing during the first execution of the body and it is possible
  # to exit with a single break statement. 
  def translate_until(sexp)
    cond1 = translate_generic_sexp(sexp[1])
    body1 = body2 = cond2 = s()
    @symbol_table.in_block do
      body1 = translate_generic_sexp(sexp[2])
      body2 = @symbol_table.in_block(true) do
         translate_generic_sexp(sexp[2])
      end
      cond2 = @symbol_table.in_block(true) do
         translate_generic_sexp(sexp[1])
      end
    end
    filtered_stmts(
      cond1,
      s(:while, s(:l_unary_oper, :'!', boolean_value(cond1.value_sexp)),
        filtered_block(
          body1,
          s(:while, s(:lit, 1),
            filtered_block(
              cond2,
              s(:if, boolean_value(cond2.value_sexp), s(:break)),
              body2)),
          s(:break))))
  end

  # A trivial break translation.
  def translate_break(sexp)
    s(:break).with_value_sexp s(:var, :nil)
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

  # Translates return statement.
  def translate_return(sexp)
    if sexp.count == 1
      ret = s().with_value(s(:var, :nil), :nil)
      @symbol_table.returned_type = :nil
    else
      ret = translate_generic_sexp(sexp[1])
      @symbol_table.returned_type = ret.value_type
    end
    filtered_stmts(ret, s(:return, ret.value_sexp)).with_value(ret.value_sexp,
                                                               ret.value_type)
  end
end
