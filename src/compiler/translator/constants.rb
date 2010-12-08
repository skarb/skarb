class Translator
  # A module consisting of functions which handle translation of constants such
  # as strings, literals and constant symbols.
  module Constants
    # Returns empty sexp with value of an constants
    # TODO: Add support for non-class constants
    def translate_const(sexp)
      s().with_value(sexp[1], sexp[1])
    end

    # Translates a literal numeric to an empty block with a value equal to a
    # :lit sexp equal to the given literal.
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
  end
end
