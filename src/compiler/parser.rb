require 'ruby_parser'

class Parser
  def parse(file)
    begin
      RubyParser.new.parse(file.read)
    rescue ParseError, SyntaxError
      puts "Input is not correct ruby source. Aborting."
      exit 1
    end
  end
end
