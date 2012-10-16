#!/bin/sh
echo 'if 5; 0 else 6 end' | skarb - || echo fail
./a.out || echo fail
rm -f a.out
