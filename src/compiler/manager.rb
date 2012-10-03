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

  Header = "#include <rubyc.h>\n"

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
