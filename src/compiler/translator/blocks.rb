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

##################################################################################
# (C) 2010-2012 Jan Stępień, Julian Zubek
# 
# This file is a part of Skarb -- Ruby to C compiler.
# 
# Skarb is free software: you can redistribute it and/or modify it under the terms
# of the GNU Lesser General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later
# version.
# 
# Skarb is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
# PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
# 
# You should have received a copy of the GNU Lesser General Public License along
# with Skarb. If not, see <http://www.gnu.org/licenses/>.
# 
##################################################################################
