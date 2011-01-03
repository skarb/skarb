def qsort(arr)
  return arr unless arr.length > 1
  pivot = arr[0]
  i = 0
  left = []
  right = []
  while (i = i + 1) < arr.length
    if arr[i] < pivot
      left.push arr[i]
    else
      right.push arr[i]
    end
  end
  left = qsort left
  right = qsort right
  left.push pivot
  i = -1
  while (i = i + 1) < right.length
    left.push right[i]
  end
  left
end

n = 200_000
arr = []
arr.push rand until (n = n - 1).zero?

qsort arr
