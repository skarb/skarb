#encoding:utf-8
#\tZażółć gęślą jaźń\n
#	Zażółć gęślą jaźń
#\\n
#\	
#	
#żółćźdźbło
#źdźbłoźdźbłoźdźbło
#6
#ł
#false
#false
#true
#3
#0.75
puts '\tZażółć gęślą jaźń\n'
puts "\tZażółć gęślą jaźń\n"
puts '\\\\n'
puts "\\\t\n\t"

a = 'źdźbło'
puts 'żółć' + a
puts a * 3
puts a.length

puts a[4]
puts a.empty?
puts a[3].empty?
puts ''.empty?

puts '5'.to_i - 2
puts '9.25'.to_f - 8.5
