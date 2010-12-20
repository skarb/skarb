#1
#2
#2
#1
#1
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
  def initialize
    @@last = self
  end
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
  def self.last
    @@last
  end
end
b=B.new
b.set(2)
puts b.get
puts b + 1
puts b == b.last
puts b.last == B.last
