class Translator
  # A module consisting of functions which handle translation of constants such
  # as strings, literals and constant symbols.
  module Constants
    # Returns empty sexp with value of an constants
    def translate_const(sexp)
      if @symbol_table.has_key? sexp[1]
        value = @symbol_table.value_of sexp[1]
        s().with_value(value.value_sexp, value.value_type).
          with_class_type value.class_type
      else
        s().with_value(sexp[1], sexp[1]).with_class_type sexp[1]
      end
    end

    # Translates constant declaration
    def translate_cdecl(sexp)
      var_name = mangle_const_name sexp[1]
      var = s(:var, var_name)
      arg = translate_generic_sexp sexp[2]
      @symbol_table.add_constant sexp[1], s().with_value(var, arg.value_type)
      @globals[var_name] = s(:decl, :'Object*', var_name)
      filtered_stmts(arg,
        s(:asgn, var, arg.value_sexp)).with_value var, arg.value_type
    end

    # Translates a literal numeric to an empty block with a value equal to a
    # :lit sexp equal to the given literal.
    def translate_lit(sexp)
      if sexp[1].floor == sexp[1]
        # It's an integer
        ctor = :Fixnum_new
        class_name = :Fixnum
      else
        # It's a float
        ctor = :Float_new
        class_name = :Float
      end
      var = next_var_name
      filtered_stmts(
         s(:decl, :'Object*', var),
         s(:asgn, s(:var, var),
           s(:call, :xmalloc,
             s(:args, s(:call, :sizeof, s(:args, s(:lit, class_name)))))),
             s(:asgn,
               s(:binary_oper, :'->', s(:var, var), s(:var, :type)),
               s(:lit, @symbol_table.id_of(class_name))),
         (:call, ctor, s(:args, s(:var, var), sexp))).with_value(s(:var, var), class_name)
    end

    # Translates a string literal.
    def translate_str(sexp)
      sexp = sexp.clone
      # No idea why does it need that many backslashes.
      sexp[1] = sexp[1].gsub('\\', '\\\\\\').gsub("\n", "\\n")

      var = next_var_name
      filtered_stmts(
         s(:decl, :'Object*', var),
         s(:asgn, s(:var, var),
           s(:call, :xmalloc,
             s(:args, s(:call, :sizeof, s(:args, s(:lit, :String)))))),
             s(:asgn,
               s(:binary_oper, :'->', s(:var, var), s(:var, :type)),
               s(:lit, @symbol_table.id_of(:String))),
         s(:call, :String_new, s(:args, s(:var, var), sexp))).with_value(s(:var, var), :String)
    end

    # Translates an array literal, such as [1, 2, "three"].
    def translate_array(sexp)
       var = next_var_name
       s = filtered_stmts(
          s(:decl, :'Object*', var),
          s(:asgn, s(:var, var),
            s(:call, :xmalloc,
              s(:args, s(:call, :sizeof, s(:args, s(:lit, :Array)))))),
              s(:asgn,
                s(:binary_oper, :'->', s(:var, var), s(:var, :type)),
                s(:lit, @symbol_table.id_of(:Array))),
                s(:call, :Array_new, s(:args, s(:var, var))))

       if sexp.count > 1
           args = sexp.rest.map { |child| translate_generic_sexp child }
           s << filtered_block(
                *args, *args.map do |arg|
                   s(:call, :Array_push, s(:args, s(:var, var), arg.value_sexp))
                end)
       end  

       s.with_value(s(:var, var), :Array)
    end

    # Translates a hash literal, such as {1 => nil, 2 => "three"}.
    def translate_hash(sexp)
      var = next_var_name
      s = filtered_stmts(
          s(:decl, :'Object*', var),
          s(:asgn, s(:var, var),
            s(:call, :xmalloc,
              s(:args, s(:call, :sizeof, s(:args, s(:lit, :Hash)))))),
              s(:asgn,
                s(:binary_oper, :'->', s(:var, var), s(:var, :type)),
                s(:lit, @symbol_table.id_of(:Hash))),
                s(:call, :Hash_new, s(:args, s(:var, var))))

      if sexp.count > 1
        args = sexp.rest.map { |child| translate_generic_sexp child }
        pairs = args.odd.zip args.even
        s <<  filtered_block(
            *args,
            *pairs.map do |key,val|
              s(:call, :Hash__INDEX__EQ_,
                s(:args, s(:var, var), key.value_sexp, val.value_sexp))
            end)
      end

      s.with_value(s(:var, var), :Hash)
  end

  # Translates a 'false'.
  def translate_false(sexp)
    s(:stmts).with_value s(:var, :false), :FalseClass
  end

  # Translates a 'true'.
  def translate_true(sexp)
    s(:stmts).with_value s(:var, :true), :TrueClass
  end
end
