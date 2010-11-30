#3
#4
#3
#5
#3
#7
#9
#6
#6
#87
#93
#13
#13
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
    puts 6
  end
  puts 9
  fun4
end

def fun5(x)
  puts x
end

def fun6(a, c, b); puts b; puts a; puts a; end

fun
fun2
fun
fun3
fun4
fun5 87
fun6 13, 29, 93
