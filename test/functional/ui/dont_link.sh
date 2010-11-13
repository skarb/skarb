#!/bin/sh
echo 0 | rubyc -c - || echo fail
test -f out.o -a ! -f a.out && \
  (file -i out.o | grep application/x-object > /dev/null) || echo fail
rm -f out.o a.out
