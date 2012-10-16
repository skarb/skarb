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

require 'compiler'
require 'emitter'
require 'translator'
require 'parser'
require 'classes_dict_builder'
require 'optimizer'

# Manages the compilation process.
class Manager
  # Reads contents of a given opened file and feeds it to the compilation
  # pipeline.
  def compile(file, options)
    code = StdlibDeclarations + file.read
    translator = Translator.new
    optimizer = Optimizer.new(translator, options)

    translated_ast = translator.translate(Parser.parse(code))
    filtered_ast = translator.expand_all_stmts(translated_ast)
    translated_code = filtered_ast.map { |x| Emitter.emit(x) }
    dict_builder = ClassesDictionaryBuilder.new translator.symbol_table
    classes_dict_code = dict_builder.emit_classes_dictionary
    final_code = Header + classes_dict_code.zip(translated_code).join
    Compiler.new.compile(final_code, options)
  end

  private

  # Contents of the stdlib.rb file.
  StdlibDeclarations = File.open(File.dirname(__FILE__) + '/stdlib.rb').read

  Header = "#include <skarb.h>\n"

end
