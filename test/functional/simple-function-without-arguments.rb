#3
#4
#3
#5
#3
#7
#9
#6
#6
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

fun
fun2
fun
fun3
fun4
