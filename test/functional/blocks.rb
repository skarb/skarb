#ok
#ok
#ok
#4 8 -12
#8
#9
#10
#11
#12
#-1;-2;-3
#-1;-2;-3
0.times { puts "fail" }
3.times { puts "ok" }
puts [1, 2, -3].map { |x| x * 4 } .join ' '

5.upto 9 do |i|
  puts i + 3
end

2.times { puts [1, 2, 3].map { |x| -1 * x } .join ";" }
