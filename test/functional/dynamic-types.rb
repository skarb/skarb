#Method "bar" in class with id 9 not found.
#a
#b
#b
class A
  def foo
    puts "a"
  end
end

class B
  def foo
    puts "b"
  end
end

class C < B
end

if 1
  o=A.new
else
  o=B.new
end
o.foo
if nil
  o=A.new
else
  o=B.new
  e=C.new
end
o.foo
e.foo
e.bar # There is no such method
e.foo # This line is not executed since program was killed with exception
