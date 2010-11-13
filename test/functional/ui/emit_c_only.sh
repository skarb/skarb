#!/bin/sh
echo 0 | rubyc -C - || echo fail
test -f out.c -a ! -f a.out && (file -i out.c | grep text/plain > /dev/null) || echo fail
rm -f out.c a.out
