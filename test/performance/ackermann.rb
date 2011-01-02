def ackermann(m, n)
  if m.zero?
    n + 1
  elsif n.zero?
    ackermann m - 1, 1
  else
    ackermann m - 1, ackermann(m, n - 1)
  end
end

puts ackermann(3,9)
