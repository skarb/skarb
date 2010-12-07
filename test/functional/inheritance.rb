#0
#2
class Parent
  def set_x(value)
    @x = value
  end

  def x
    @x
  end
end

class Child < Parent
  def set_x(value)
    @x = 0
  end
end

child = Child.new
child.set_x 2
puts child.x
parent = Parent.new
parent.set_x 2
puts parent.x
