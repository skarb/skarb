#!/bin/sh
rm -f a.out
skarb $srcdir/test_code.rb || echo fail
./a.out || echo error!
rm -f a.out
