#encoding: utf-8
#0
#2
#3,,5
#fooąą1ąxą3.1415ąbar
a = Array.new
puts a.length
b = [4]
a.push 4
puts 'fail0' if a != b
b = [3, 4]
puts 'fail1' if a == b
a.unshift 3
puts a.length
puts 'fail2' if a != b
b.pop
a.delete 4
puts 'fail3' if a != b
puts 'fail4' unless b[1] == nil
a[2] = 5
puts 'fail5' unless a[1] == nil
puts a.join ','
c = ["foo", nil, 1, "x", 3.1415, "bar"]
puts c.join 'ą'
