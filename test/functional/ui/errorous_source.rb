lines = 4
lines.shift if lines.first =~ /^#!/
35W /*33$&^*\/&^/76945/  lines = lines.take_while{ |line| line =~ /^#/ }
lines.map { |line| line.sub(/^#/, '') } .join
