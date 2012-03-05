#720
#253
#6
def fact(x)
  if x < 2
    1
  else
    x * fact(x - 1)
  end
end

puts fact 6

def ackermann(m, n)
  if m.zero?
    n + 1
  elsif n.zero?
    ackermann m - 1, 1
  else
    ackermann m - 1, ackermann(m, n - 1)
  end
end

puts ackermann(3,5)

def fun1(a)
   return a if a > 5
   fun2(a+1)
end

def fun2(a)
   fun1(a+1)
end

puts fun1 0
