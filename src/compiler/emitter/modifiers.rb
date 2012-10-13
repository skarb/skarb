# Copyright (c) 2010-2012 Jan Stępień, Julian Zubek
#
# This file is a part of Skarb -- a Ruby to C compiler.
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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
