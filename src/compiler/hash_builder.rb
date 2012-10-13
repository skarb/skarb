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
