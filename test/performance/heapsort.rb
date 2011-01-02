# The Great Computer Language Shootout
# http://shootout.alioth.debian.org/
#
# modified by Jabari Zakiya
def heapsort(ra)
  n = ra.length
  j = 0
  i = 0
  rra = 0
  l = (n / 2 + 1)
  ir = n - 1

  while (1)
    if (l > 1)
      l = l - 1
      rra = ra[l]
    else
      rra = ra[ir]
      ra[ir] = ra[1]
      ir = ir - 1
      if ir == 1
        ra[1] = rra
        return
      end
    end
    i = l
    j = l * 2
    while not (j > ir)
      if (j < ir)
          if (ra[j] < ra[j+1])
            j = j + 1
          end
      end
      if (rra < ra[j])
        ra[i] = ra[j]
        i = j
        j = j + i
      else
        j = ir + 1
      end
    end
    ra[i] = rra
  end
end

n = 100_000
arr = []
arr.push rand until (n = n - 1).zero?

heapsort arr
