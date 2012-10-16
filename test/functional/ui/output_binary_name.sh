#!/bin/sh
echo 1 | skarb -o output_binary -
test -x output_binary || echo fail
rm -f output_binary
