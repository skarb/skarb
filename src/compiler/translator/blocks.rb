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
