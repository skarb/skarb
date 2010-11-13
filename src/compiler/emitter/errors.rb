module Emitter::Errors
  class UnexpectedSexpError < Exception
    def initialize(type)
      super "Unexpected sexp type: #{type}"
    end
  end
end
