#1
class A
end
class B < A
  def set_x(x)
    @x=x
  end
end
b = B.new
b.set_x(1)
class A
  def get_x
    @x
  end
end
puts b.get_x
