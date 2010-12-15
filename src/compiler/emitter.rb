require 'stringio'
require 'extensions'

# Generates code from given C abstract syntax tree. It does
# not perform any validation.
class Emitter
  def Emitter.emit(sexp)
    emit_generic_elem(sexp)
  end

  private

  %w{assignments blocks flow_control functions literals macros operators helpers
    modifiers composite errors
  }.each do |file|
    require 'emitter/' + file
  end

  include Assignments
  include Blocks
  include FlowControl
  include Functions
  include Literals
  include Macros
  include Operators
  include Modifiers
  include Composite
  include Errors

  def Emitter.emit_cast(sexp)
    '(' + sexp[1].to_s + ')' + emit_arg_expr(sexp[2])
  end

  # Universal function for emitting any argument expression
  # with correct parenthesis
  def Emitter.emit_arg_expr(elem)
    case elem[0]
    when :str, :lit, :var, :decl, :init_block
      emit_generic_elem(elem)
    else
      '(' + emit_generic_elem(elem) + ')'
    end
  end

  # Emits a symbol or executes a "emit_..." method according to the sexp[0]
  # symbol.
  def Emitter.emit_generic_elem(sexp)
    if sexp.is_a? Symbol
      sexp
    elsif sexp.is_a? Sexp
      begin
        Emitter.send 'emit_' + sexp[0].to_s, sexp
      rescue NoMethodError
        raise UnexpectedSexpError.new sexp[0]
      end
    end
  end
end
