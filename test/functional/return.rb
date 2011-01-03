#3
#foobarasdf
#0
def foo(x)
  return 2 if x < 5
  "foobar"
end

puts (foo 1) + 1
puts (foo 6) + "asdf"

def r_b(i)
  r_a(i-1)
end

def r_a(i)
  return r_b(i) if i>0
  i
end

puts r_a(5)
