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

require 'tempfile'
require 'fileutils'
require 'helpers'
require 'config'

# Files created by Tempfile are placed in the /tmp directory. As a result all
# files produced during the compilation process (excl. the output binary) are
# created in the /tmp directory.
class Compiler
  include Helpers

  # Launches the compilation process for the given code. Following options are
  # optional.
  # - +emit_only+ should be true when the C compiler shouldn't be run. The
  #   default value is false.
  # - +dont_link+ should be true when the linking shouldn't be done. It's false
  #   by default.
  # - +output+ contains the name of the target output file.
  def compile(code, opts = {})
    parse_options opts
    @code = code
    if @emit_only
      output_code File.open(@output, 'w')
    else
      full_compilation
    end
  end

  private

  # Parses the options hash passed to the compile method.
  def parse_options(opts)
    @emit_only = opts[:emit_only] || false
    @dont_link = (not @emit_only and opts[:dont_link]) || false
    @output = opts[:output] || default_output
  end

  # Returns the output file name depending on whether we are doing a full
  # compilation process.
  def default_output
    if @emit_only
      'out.c'
    else
      'a.out'
    end
  end

  # Outputs the code to a given opened file and close it afterwards.
  def output_code(file)
     file.write @code
     file.close
  end

  # Performs a full compilation: saves the code in a temporary file, runs a C
  # compiler and a linker.
  def full_compilation
    with_code_in_a_tempfile do |path|
      begin
        spawn_cc path
        link path unless @dont_link
      rescue => err
        output_code File.open('output.c', 'w')
        die 'The C compiler failed. Aborting.'
      end
    end
  end

  # Writes the code to a temporary file and passes its path to a given block.
  def with_code_in_a_tempfile
    Tempfile.open ['skarb', '.c'] do |file|
      output_code file
      yield file.path
    end
  end

  # Links the object file and cleans up afterwards.
  def link(c_filename)
    obj_filename = object_file c_filename
    spawn_linker obj_filename
    FileUtils.rm_f obj_filename
  end

  # Returns an object file name for a given source file name.
  def object_file(source_file)
    if @dont_link
      'out.o'
    else
      source_file.sub /\.c$/, '.o'
    end
  end

  # Creates the object file by starting the C compiler in a child process.
  def spawn_cc(filename)
    system(cc + " #{cflags} -c -o #{object_file filename} #{filename}")
    raise_if_child_failed 'cc failed!'
  end

  # Links the object file by starting the C compiler in a child process.
  def spawn_linker(filename)
    system("#{cc} -o #{@output} #{filename} #{ldflags}")
    raise_if_child_failed 'linker failed!'
  end

  # Raises a given error if the child exited with a non-zero status.
  def raise_if_child_failed(msg)
    raise msg if $?.exitstatus != 0
  end

  # Returns a command starting a C compiler
  def cc
    ENV['CC'] || 'cc'
  end

  # Returns CFLAGS set using the environment variable.
  def cflags
    "-I#{Configuration::IncludeDir} #{ENV['CFLAGS']}"
  end

  # Returns flags used during linking, including the LDFLAGS environment
  # variable.
  def ldflags
    "-L#{Configuration::LibDir} -lskarb -lgc #{ENV['LDFLAGS']}"
  end
end
