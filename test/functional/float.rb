#5.375
#5.375
#-1.125
#1.125
#ok
#ok
#ok
#10.25
#2.25
a = 3.25
b = 2.125
puts a + b
puts b + a
puts b - a
puts a - b
puts 'ok' if a > b
puts 'fail' if a < b
puts 'fail' if a == b
b = 3.25
puts 'ok' if a == b
b = a + b
puts 'ok' if a < b

# Mixing Float with Fixnum

a = 3.25
puts a + 7
puts a - 1
puts '> fail' if a > 4
puts '< fail' if a < 3
a = 4.0
puts '== fail' unless a == 4
