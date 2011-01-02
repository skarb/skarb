#0
#1
#2
#ok
def self.sfun
  puts 0
end
sfun

def fun
  puts 1
end
fun

def self.fun
  puts 2
end
fun

a = class A
  a = new
end
puts "ok" if a != nil
