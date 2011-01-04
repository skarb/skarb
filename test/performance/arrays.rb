i = 0
max = 1000000
array = [0]
while i<max
  r = (rand * array.length).floor
  array.push array[r]
  i += 1
end
puts array.length
