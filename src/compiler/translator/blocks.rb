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

require 'translator/functions'

class Translator
  # Handles translation of Ruby blocks. Blocks are passed to method which accept
  # them by using functions declared in blocks.h. It's not the most elegant nor
  # the safest solution as it involves typical risks caused by altering the
  # global state.
  module Blocks
    include Functions

    # Translates the iter sexp which represents Ruby blocks. Currently no
    # arguments can be passed.
    def translate_iter(sexp)
      raise 'Blocks cannot accept more than 1 argument' if count_args(sexp) > 1
      name = next_block_name
      implement_function name, make_defn(sexp), []
      call = translate_call sexp[1]
      filtered_stmts(
        s(:call, :push_block, s(:args, s(:cast, :block_t, s(:var, name)))),
        call,
        s(:call, :pop_block, s(:args))).with_value_of call
    end

    private

    def count_args(sexp)
      if sexp[2].nil?
        0
      elsif sexp[2][0] == :lasgn
        1
      else
        2
      end
    end

    # Each call to this method returns a new, unique block name.
    def next_block_name
      @next_block_id ||= 0
      "block#{@next_block_id += 1}".to_sym
    end

    # Returns a Ruby defn sexp which defines the block as if it was a function.
    def make_defn(sexp)
      args = s(:args)
      args << sexp[2][1] if sexp[2]
      s(:defn, :block, args,
        s(:scope,
          s(:block,
            sexp[3])))
    end
  end
end
