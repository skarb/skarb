require 'stringio'

# Extensions for standard Array class
class Array

  # Returns a slice from the middle of the array
  # - a -- index of first char of the slice
  # - b -- negative index of last char of the slice
  def middle(a=1, b=-1)
    return self[a..self.length+b-1]
  end

  # Returns fragment from supplied index to the end of the array
  def rest(index=1)
    return self[index..self.length-1] if index >= 0
    return self[0, self.length+index]
  end

end

# Generates code from given C abstract syntax tree. It does
# not perform any validation.
class Emitter
  def emit(sexp)
    return MinimalCode if sexp.nil?
    @out = StringIO.new
    emit_generic_elem(sexp)
    return @out.string
  end

  private

  MinimalCode = "int main(){return 0;}"

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
  include Helpers
  include Modifiers
  include Composite
  include Errors

  # Universal function for emitting any argument expression
  # with correct parenthesis
  def emit_arg_expr(elem)
    case elem[0]
    when :str, :lit, :var
      emit_generic_elem(elem)
    else
      in_parentheses { emit_generic_elem(elem) }
    end
  end

  # Emits symbol or executes method "emit_..." according sexp[0] symbol
  def emit_generic_elem(sexp)
    if sexp.is_a? Symbol
      @out << sexp
    elsif sexp.is_a? Sexp
      begin
        self.send 'emit_' + sexp[0].to_s, sexp
      rescue NoMethodError
        raise UnexpectedSexpError.new sexp[0]
      end
    end
  end
end
