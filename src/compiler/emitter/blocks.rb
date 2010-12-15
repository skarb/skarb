# Blocks
# - :block -- "{" + statements + "}"
# - :init_block -- "{" + values + "}"
module Emitter::Blocks
  def Emitter.emit_file(sexp)
    sexp.rest.map do |elem|
      emit_generic_elem(elem) + (';' if needs_semicolon? elem).to_s
    end.join
  end

  def Emitter.emit_block(sexp)
    '{' + sexp.rest.map { |elem| emit_generic_elem(elem) + ';' }.join + '}'
  end

  def Emitter.emit_init_block(sexp)
    return '{}' if sexp.length == 1
    '{' + sexp.rest.map { |elem| emit_generic_elem(elem) }.join(',') + '}'
  end

  private

  def Emitter.needs_semicolon?(sexp)
    not [:define, :include, :defn].include? sexp[0]
  end
end

