require 'ruby_parser'

# Responsible for parsing Ruby source code and creating ASTs. Behind the scenes
# it uses RubyParser.
class Parser
  # Returns an AST for a given string with Ruby code.
  def parse(input)
    begin
      RubyParser.new.parse(input)
    rescue ParseError, SyntaxError
      puts "Input is not correct ruby source. Aborting."
      exit 1
    end
  end
end
