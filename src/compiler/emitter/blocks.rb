# Blocks
# - :block -- "{" + statements + "}"
module Emitter::Blocks
  def emit_file(sexp)
    sexp.rest.map do |elem|
      emit_generic_elem(elem) + (';' if needs_semicolon? elem).to_s
    end.join
  end

  def emit_block(sexp)
    '{' + sexp.rest.map { |elem| emit_generic_elem(elem) + ';' }.join + '}'
  end

  def emit_init_block(sexp)
    return '{}' if sexp.length == 1
    '{' + emit_generic_elem(sexp[1]) +
      sexp.rest(2).map { |elem| ',' + emit_generic_elem(elem) }.join + '}'
  end

  private

  def needs_semicolon?(sexp)
    not [:define, :include, :defn].include? sexp[0]
  end
end

