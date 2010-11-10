require 'tempfile'

class Compiler
  def compile(code)
    Tempfile.open 'rubyc.c' do |file|
      file.write code
      file.close
      spawn_cc file.path
      spawn_linker file.path + '.o'
    end
  end

  private

  def spawn_cc(filename)
    if (child = fork).nil?
      exec "gcc -x c -c -o #{filename}.o #{filename}"
    end
    Process.wait child
    raise "gcc failed!" if $?.exitstatus != 0
  end

  def spawn_linker(obj_file)
    if (child = fork).nil?
      exec "gcc -o a.out #{obj_file}"
    end
    Process.wait child
    raise "gcc failed!" if $?.exitstatus != 0
  end
end