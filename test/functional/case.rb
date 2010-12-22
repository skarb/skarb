#ok
#ok
x = 3 + 4
ret = case x
      when 6
        'fail1'
      when 9
        'fail2'
      when 7
        'ok'
      else
        'fail3'
      end
puts ret

a = 123

case a
when 5
  puts 'fail4'
else
  puts 'ok'
end
