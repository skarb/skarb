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
      raise 'Blocks cannot accept arguments' if sexp[2]
      name = next_block_name
      implement_function name, make_defn(sexp), []
      filtered_stmts(
        s(:call, :set_block, s(:args, s(:var, name))),
        translate_call(sexp[1]),
        s(:call, :unset_block, s(:args)))
    end

    private

    # Each call to this method returns a new, unique block name.
    def next_block_name
      @next_block_id ||= 0
      "block#{@next_block_id += 1}".to_sym
    end

    # Returns a Ruby defn sexp which defines the block as if it was a function.
    def make_defn(sexp)
      s(:defn, :block, s(:args),
        s(:scope,
          s(:block,
            sexp[3])))
    end
  end
end
