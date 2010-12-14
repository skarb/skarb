#5
#5
#-1
#1
#ok
#ok
#ok
#3.5
#1.5
a = 3
b = 2
puts a + b
puts b + a
puts b - a
puts a - b
puts 'ok' if a > b
puts 'fail' if a < b
puts 'fail' if a == b
b = 3
puts 'ok' if a == b
b = a + b
puts 'ok' if a < b

# Mixing Fixnum with Float

a = 3
puts a + 0.5
puts a - 1.5
puts '> fail' if a > 3.1
puts '< fail' if a < 2.9
puts '== fail' unless a == 3.0
