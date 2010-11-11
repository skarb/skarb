#!/bin/sh
rm -f a.out
rubyc $srcdir/uitester.rb || echo fail
./a.out || echo error!
rm -f a.out
