require 'open3'

# This class is a tool for building static hash table from a given
# set of key-value pairs and expressing it in C code. It is uses
# gperf to perform this task.
class HashBuilder
  
  EnumPattern = /enum.*?};/m
  FirstFindMethodLine = "if (len <="

  # Returns C code defining hash table populated with given pairs.
  def self.emit_table(name, struct_name, data)
    input = "#{struct_name}\n%%\n"
    data.each do |record|
      input += record.join(',') + "\n"
    end
    output = ""
    cmd = "gperf -G -t -E -T -H #{name}_hash -N #{name}_method_find -W #{name}_words -I"
    Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thread|
      stdin.write input
      stdin.close
      wait_thread.join
      output = stdout.read
    end
    # As a result of gperf bug we have to change order of some output
    unless output == ""
      enum = output[EnumPattern]
      output[EnumPattern] = ""
      output[FirstFindMethodLine] = enum + "\n" + FirstFindMethodLine
    end
    output
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
