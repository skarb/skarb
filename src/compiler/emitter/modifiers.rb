require 'emitter/helpers'
# == Modifiers
# Modifiers encapsulate variables definitions, they can be nested in
# each other.
# - :unsigned
# - :signed
# - :const
# - :volatile
# - :static
# - :auto
# - :extern
# - :register
module Emitter::Modifiers
  include Emitter::Helpers

  alias :emit_unsigned :output_type_and_children
  alias :emit_signed :output_type_and_children
  alias :emit_const :output_type_and_children
  alias :emit_volatile :output_type_and_children
  alias :emit_static :output_type_and_children
  alias :emit_auto :output_type_and_children
  alias :emit_extern :output_type_and_children
  alias :emit_register :output_type_and_children

end
