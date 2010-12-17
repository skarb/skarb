a = Array.new
b = [4]
a.push 4
puts 'fail0' if a != b
b = [3, 4]
puts 'fail1' if a == b
a.unshift 3
puts 'fail2' if a != b
b.pop
a.delete 4
puts 'fail3' if a != b
