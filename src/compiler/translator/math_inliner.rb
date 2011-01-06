class Translator
  # Class responsible for inlining arithmetic expressions.
  class MathInliner 

    class NotInlineableError < Exception
    end

    include Mangling

    def initialize(symbol_table)
      @symbol_table = symbol_table
    end

    # Attempts to translate sexp as an arithmetic expression containing operators,
    # local variables and literals.
    def translate(sexp)
      begin
        t = translate_generic_sexp sexp
        ctor = (t.value_type.to_s+'_new').to_sym
        s(:stmts).with_value s(:call, ctor, s(:args, t.value_sexp)), t.value_type
      rescue NotInlineableError
        nil
      end
    end

    # Returns true if MathInliner can inline a given call sexp.
    def inlineable? sexp
      InlinedOperators.include? sexp[2]
    end

    protected

    InlinedOperators = [:+, :-, :*, :/]

    # Calls one of translate_* methods depending on the given sexp's type.
    def translate_generic_sexp(sexp)
      # Is there a public or a private method translating such a sexp?
      if respond_to? (method_name = "translate_#{sexp[0]}".to_sym), true
        send method_name, sexp
      else
        raise NotInlineableError 
      end
    end

    # Returns value extracted from Fixnum or Float object pointed by local variable.
    # Throws NotInlineableError if variable is of different type.
    def translate_lvar(sexp)
      raise NotInlineableError unless @symbol_table.has_lvar? sexp[1]
      var_type = @symbol_table.get_lvar_type sexp[1] 
      raise NotInlineableError unless [Fixnum, Float].include? var_type 
      var_name = mangle_lvar_name sexp[1]
      s().with_value s(:binary_oper,
                       :'->', s(:cast, var_type.to_s.to_sym.star,
                                s(:var, var_name)), s(:var, :val)), var_type
    end

    # Returns literal value if it is a number.
    # Throws NotInlineableError otherwise.
    def translate_lit(sexp)
      var_type = sexp[1].class
      raise NotInlineableError unless [Fixnum, Float].include? var_type 
      s().with_value s(:lit, sexp[1]), var_type
    end

    # Translates calls corresponding to arithmetic operators.
    def translate_call(sexp)
      raise NotInlineableError unless inlineable? sexp
      arg1 = translate_generic_sexp sexp[1]
      arg2 = translate_generic_sexp sexp[3][1]
      res_type = ([arg1.value_type, arg2.value_type].include? Float) ? Float : Fixnum
      s().with_value s(:binary_oper,
                       sexp[2], arg1.value_sexp, arg2.value_sexp), res_type
    end
  end
end
