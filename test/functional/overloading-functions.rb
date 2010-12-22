#Method "bar" in class with id 11 not found.
#3
#6.5
#4
#9
#foo
#foo1
def fun(x)
  puts x
end
fun 3
fun 6.5
fun 4
def fun(x)
  x*x
end
puts fun 3

class A
  def foo
    puts "foo"
  end
end
if 1
  a = A.new
end
a.foo
class A
  def foo
    puts "foo1"
  end
end
a.foo
a.bar
class A
  def bar
    puts "bar"
  end
end

