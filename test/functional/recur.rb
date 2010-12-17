#720
def fact(x)
  if x < 2
    1
  else
    x * fact(x - 1)
  end
end

puts fact 6
