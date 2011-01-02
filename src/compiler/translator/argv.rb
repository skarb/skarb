class Translator
  module ARGV
    def prepare_argv
      translate_cdecl s(:const, :ARGV, s(:array))
    end

    # Build ARGV
    ARGVInitialization = s(:call, :prepare_argv,
                           s(:args,
                             s(:l_unary_oper, :&, s(:var, :'c_ARGV')),
                             s(:var, :argc),
                             s(:var, :args)))
  end
end
