# Blocks
# - :subblock -- multiple lines ended by ";"
# - :block -- "{" + subblock + "}"
module Emitter::Blocks
  def emit_block(sexp)
    @out << "{\n"
    emit_subblock(sexp)
    @out << "}\n"
  end

  def emit_subblock(sexp)
    sexp.rest.each do |elem|
      case elem[0]
      when :define, :include, :defn
        emit_generic_elem(elem)
      else
        emit_generic_elem(elem)
        @out << ";\n"
      end
    end
  end
end
