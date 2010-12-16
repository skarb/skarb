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
        type = Fixnum
      else
        # It's a float
        ctor = :Float_new
        type = Float
      end
      s(:stmts).with_value(s(:call, ctor, s(:args, sexp)), type)
    end

    # Translates a string literal.
    def translate_str(sexp)
      sexp = sexp.clone
      # No idea why does it need that many backslashes.
      sexp[1] = sexp[1].gsub('\\', '\\\\\\').gsub("\n", "\\n")
      s(:stmts).with_value(s(:call, :String_new, s(:args, sexp)), String)
    end

    # Translates an array literal, such as [1, 2, "three"].
    def translate_array(sexp)
      if sexp.count == 1
        s().with_value s(:call, :Array_new, s(:args)), :Array
      else
        args = sexp.rest.map { |child| translate_generic_sexp child }
        var = next_var_name
        filtered_stmts(
          s(:decl, :'Object*', var),
          s(:asgn, s(:var, var), s(:call, :Array_new, s(:args))),
          filtered_block(
            *args,
            *args.map { |arg| s(:call, :Array_push,
                                s(:args, s(:var, var), arg.value_sexp)) }
        )).with_value s(:var, var), :Array
      end
    end
  end
end
