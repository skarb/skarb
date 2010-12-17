#1
#2
#2
class Empty
end
class A
  def initialize(a)
    @a=a
    puts @a
  end
end
A.new(1)
class B
  def set(a)
    @a=a
  end
  def get
    @a
  end
  # Operator
  def +(a)
    a + 1
  end
end
b=B.new
b.set(2)
puts b.get
puts b + 1
