#1
#2
#2
#last
#
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
  def last
    "last"
  end
  def self.last
    @@last
  end
end
b=B.new
b.set(2)
puts b.get
puts b + 1
puts b.last
puts b.last == B.last
C = 1
puts C * 2
