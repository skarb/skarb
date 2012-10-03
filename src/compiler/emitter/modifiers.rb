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

  class << Emitter
    alias :emit_unsigned :output_type_and_children
    alias :emit_signed :output_type_and_children
    alias :emit_const :output_type_and_children
    alias :emit_volatile :output_type_and_children
    alias :emit_static :output_type_and_children
    alias :emit_auto :output_type_and_children
    alias :emit_extern :output_type_and_children
    alias :emit_register :output_type_and_children
  end
end

##################################################################################
# (C) 2010-2012 Jan Stępień, Julian Zubek
# 
# This file is a part of Skarb -- Ruby to C compiler.
# 
# Skarb is free software: you can redistribute it and/or modify it under the terms
# of the GNU Lesser General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later
# version.
# 
# Skarb is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
# PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
# 
# You should have received a copy of the GNU Lesser General Public License along
# with Skarb. If not, see <http://www.gnu.org/licenses/>.
# 
##################################################################################
