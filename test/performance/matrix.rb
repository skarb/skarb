# http://shootout.alioth.debian.org/
#
# Contributed by Christopher Williams
size = 130

def mkmatrix(rows, cols)
  count = 0
  matrix = []
  until rows.zero?
    row = []
    i = cols
    row.push(i = i - 1) until i.zero?
    matrix.push row
    rows = rows - 1
  end
  matrix
end

def mmult(rows, cols, m1, m2)
  m3 = []
  i = 0
  while i < rows
    row = []
    j = 0
    while j < cols
      val = 0
      k = 0
      while k < cols
        val = val + m1[i][k] * m2[k][j]
        k = k + 1
      end
      row.push val
      j = j + 1
    end
    m3.push row
    i = i + 1
  end
  m3
end

m1 = mkmatrix(size, size)
m2 = mkmatrix(size, size)
mm = mmult(size, size, m1, m2)
