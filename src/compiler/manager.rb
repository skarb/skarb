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
