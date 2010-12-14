#5
#5
#ok
#ok
#ok
#6
a = 3
b = 2
puts a + b
puts b + a
puts 'ok' if a > b
puts 'fail' if a < b
puts 'fail' if a == b
b = 3
puts 'ok' if a == b
b = a + b
puts 'ok' if a < b
puts b.to_s
