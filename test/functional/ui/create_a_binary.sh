#!/bin/sh
rm -f a.out
rubyc $srcdir/test_code.rb || echo fail
./a.out || echo error!
rm -f a.out
