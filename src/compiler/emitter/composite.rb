require 'emitter/helpers'
# == Composite types
# - :typedef
# - :enum
# - :union
# - :struct
module Emitter::Composite
  include Emitter::Helpers

  alias :emit_typedef :output_type_and_children
  alias :emit_enum :output_type_and_children
  alias :emit_union :output_type_and_children
  alias :emit_struct :output_type_and_children
end
