# Blocks
# - :block -- "{" + statements + "}"
module Emitter::Blocks
  def emit_block(sexp)
    @out << "{\n"
    sexp.rest.each do |elem|
      case elem[0]
      when :define, :include, :defn
        emit_generic_elem(elem)
      else
        emit_generic_elem(elem)
        @out << ";\n"
      end
    end
    @out << "}\n"
  end
end
