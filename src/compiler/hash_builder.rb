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
    cmd = "gperf -G -t -E -T -H #{name}_hash -N #{name}_method_find -W #{name}_words"
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
