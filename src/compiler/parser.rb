require 'ruby_parser'

# Responsible for parsing Ruby source code and creating ASTs. Behind the scenes
# it uses RubyParser.
class Parser
  # Returns an AST for a given string with Ruby code.
  def Parser.parse(input)
    begin
      RubyParser.new.parse(input)
    rescue ParseError, SyntaxError
      puts "Input is not correct ruby source. Aborting."
      exit 1
    end
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
