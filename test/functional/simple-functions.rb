#3
#4
#3
#5
#3
#7
#9
#a co to?
#a co to?
#87
#93
#13
#13
#132
#qweasd
#qweasd
#3
#4.5
def fun
  puts 3
end

def fun2
  puts 4
  1235
  fun
  puts 5
end

def fun3
  puts 7
  def fun4
    puts "a co to?"
  end
  puts 9
  fun4
end

def fun5(x)
  puts x
end

def fun6(a, c, b); puts b; puts a; puts a; end

def fun7(x); x; end

fun
fun2
fun
fun3
fun4
fun5 87
fun6 13, "foobar", 93
fun6 'qweasd', 43, 132
puts fun7 3
puts fun7 4.5
