# The Computer Language Benchmarks Game
# http://shootout.alioth.debian.org
#
# contributed by Jesse Millikan
# Modified by Wesley Moxam and Michael Klaus


def item_check(left, item, right)
  return item if left.nil?
  item + item_check(left[0],left[1],left[2]) - item_check(right[0],right[1],right[2])
end

def bottom_up_tree(item, depth)
  return [nil, item, nil] if depth == 0
  item_item = 2 * item
  depth -= 1
  [bottom_up_tree(item_item - 1, depth), item, bottom_up_tree(item_item, depth)]
end

#max_depth = ARGV[0].to_i
max_depth = 13
min_depth = 4

max_depth = [min_depth + 2, max_depth].max

stretch_depth = max_depth + 1
stretch_tree = bottom_up_tree(0, stretch_depth)

puts "stretch tree of depth"
puts stretch_depth
puts "check:"
puts item_check(stretch_tree[0], stretch_tree[1], stretch_tree[2])

stretch_tree = nil

long_lived_tree = bottom_up_tree(0, max_depth)

base_depth = max_depth + min_depth

depth = min_depth
while depth < max_depth + 2
  iterations = 2 ** (base_depth - depth)

  check = 0

  i = 1
  while i < iterations + 1
    temp_tree = bottom_up_tree(i, depth)
    check += item_check(temp_tree[0], temp_tree[1], temp_tree[2])

    temp_tree = bottom_up_tree(-i, depth)
    check += item_check(temp_tree[0], temp_tree[1], temp_tree[2])
    i += 1
  end

  puts iterations * 2
  puts "trees of depth"
  puts depth
  puts "check:"
  puts check

  depth += 2
end

puts "long lived tree of depth"
puts max_depth
puts "check:"
puts item_check(long_lived_tree[0], long_lived_tree[1], long_lived_tree[2])

