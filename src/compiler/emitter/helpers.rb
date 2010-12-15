# Helpers outputting commonly used characters or constructions.
module Emitter::Helpers
  # Emits the sexp's type and its elements separated with spaces.
  def Emitter.output_type_and_children(sexp)
    ([sexp[0]] + sexp.rest.map { |elem| emit_generic_elem(elem) }).join ' '
  end
end
