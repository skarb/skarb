#!/bin/sh
rubyc $srcdir/uitester.rb || echo fail
./a.out || echo error!
