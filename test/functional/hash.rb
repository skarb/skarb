a = Hash.new
puts 'fail0' if a[2]
a = {1 => 4, 2 => 3}
puts 'fail1' unless a[2]
a.delete 2
puts 'fail2' if a[2]
a[2] = 6
puts 'fail3' unless a[2]