require 'tempfile'
require 'fileutils'
require 'helpers'

# Files created by Tempfile are placed in the /tmp directory. As a result all
# files produced during the compilation process (excl. the output binary) are
# created in the /tmp directory.
class Compiler
  include Helpers

  def compile(code, opts = {})
    @output = opts[:output] || 'a.out'
    Tempfile.open ['rubyc', '.c'] do |file|
      file.write code
      file.close
      begin
        spawn_cc file.path
        spawn_linker object_file file.path
        clean_up file.path
      rescue => e
        File.open('output.c', 'w').write(code)
        die 'The C compiler failed. Aborting.'
      end
    end
  end

  private

  # Returns an object file name for a given source file name.
  def object_file(source_file)
    source_file.sub /\.c$/, '.o'
  end

  def spawn_cc(filename)
    if (child = fork).nil?
      exec_or_exit cc + " -c -o #{object_file filename} #{filename}"
    end
    Process.wait child
    raise_if_child_failed 'cc failed!'
  end

  def spawn_linker(filename)
    if (child = fork).nil?
      exec_or_exit cc + " -o #{@output} #{filename}"
    end
    Process.wait child
    raise_if_child_failed 'linker failed!'
  end

  # Calls exec and in case of failure calls exit afterwards.
  def exec_or_exit(cmd)
    begin
      exec cmd
    rescue SystemCallError
      exit 1
    end
  end

  # Removes artifacts after a successful compilation.
  def clean_up(filename)
    FileUtils.rm_f object_file filename
  end

  # Raises a given error if the child exited with a non-zero status.
  def raise_if_child_failed(msg)
    raise msg if $?.exitstatus != 0
  end

  # Returns a command starting a C compiler
  def cc
    ENV['CC'] || 'cc'
  end
end
