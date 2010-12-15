require 'compiler'
require 'emitter'
require 'translator'
require 'parser'
require 'classes_dict_builder'

# Manages the compilation process.
class Manager
  # Reads contents of a given opened file and feeds it to the compilation
  # pipeline.
  def compile(file, options)
    code = stdlib_declarations + file.read
    translator = Translator.new
    translated_ast = translator.translate(Parser.new.parse(code))
    translated_code = translated_ast.map { |x| Emitter.emit(x) }
    classed_dict_code = ClassesDictionaryBuilder.emit_classes_dictionary(
      translator.symbol_table)
    final_code = Header + translated_code.zip(classed_dict_code).join 
    Compiler.new.compile(final_code, options)
  end

  private

  Header = "#include <rubyc.h>\n"

  # Returns contents of the stdlib.rb file.
  def stdlib_declarations
    File.open(File.dirname(__FILE__) + '/stdlib.rb').read
  end
end
