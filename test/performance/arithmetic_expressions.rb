j = 0
while j < 100
  i = 0
  a = 0
  while i < 50000
    a = a + (0.0000000001 * a - 7) * 0.5
    i += 1
  end
  j += 1
end
puts a
