#0
#1
#0
#var2
#ok
#1
_var2 = "var2"

def fun
  puts 0
end
fun
def fun_1
  puts "error"
end
def fun
  puts 1
end
fun

c_ARGV = "abc"
puts ARGV.length

puts _var2

class A
  def self.fun
    puts "ok"
  end

  def s_fun
    puts "error"
  end
end
A.fun

$a = 1
g_a = 2
puts $a
