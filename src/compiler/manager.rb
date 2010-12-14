require 'compiler'
require 'emitter'
require 'translator'
require 'parser'

# Manages the compilation process.
class Manager
  # Reads contents of a given opened file and feeds it to the compilation
  # pipeline.
  def compile(file, options)
    code = stdlib_declarations + file.read
    Compiler.new.compile(Emitter.new.emit(
      Translator.new.translate(Parser.new.parse(code))), options)
  end

  private

  # Returns contents of the stdlib.rb file.
  def stdlib_declarations
    File.open(File.dirname(__FILE__) + '/stdlib.rb').read
  end
end
