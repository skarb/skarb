require 'ruby_parser'

# Responsible for parsing Ruby source code and creating ASTs. Behind the scenes
# it uses RubyParser.
class Parser
  # Reads contents of a given opened file and returns an AST for it.
  def parse(file)
    begin
      RubyParser.new.parse(file.read)
    rescue ParseError, SyntaxError
      puts "Input is not correct ruby source. Aborting."
      exit 1
    end
  end
end
