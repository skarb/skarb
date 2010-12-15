require 'open3'

# This class is a tool for building static hash table from a given
# set of key-value pairs and expressing it in C code. It is uses
# gperf to perform this task.
class HashBuilder
  # Returns C code defining hash_elem struct used in all hash tables.
  def self.emit_hash_elem_struct
    "typedef struct { char* name; void* val; } hash_elem;"
  end
  
  # Returns C code defining hash table populated with given pairs.
  def self.emit_table(name, pairs)
    input = "hash_elem\n%%\n"
    pairs.each do |pair|
      input += pair.join(',') + "\n"
    end
    output = ""
    cmd = "gperf -t -E -T -H #{name}_hash -N #{name}_method_find"
    Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thread|
      stdin.write input
      stdin.close
      wait_thread.join
      output = stdout.read
    end
    output 
  end
end
