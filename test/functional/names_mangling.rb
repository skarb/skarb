#0
#1
#0
#var2
#ok
#1
_var2 = "var2"

def fun
  puts 0
end
fun
def fun_1
  puts "error"
end
def fun
  puts 1
end
fun

c_ARGV = "abc"
puts ARGV.length

puts _var2

class A
  def self.fun
    puts "ok"
  end

  def s_fun
    puts "error"
  end
end
A.fun

$a = 1
g_a = 2
puts $a

class Int
end
Char = 1
$int = 1
@int = 1
@@int = 1

auto=1
char=1
const=1
continue=1
default=1
double=1
enum=1
extern=1
float=1
goto=1
int=1
long=1
register=1
short=1
signed=1
sizeof=1
static=1
struct=1
switch=1
typedef=1
union=1
unsigned=1
void=1
volatile=1
