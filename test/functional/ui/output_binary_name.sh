#!/bin/sh
echo puts 1 | rubyc -o output_binary -
test -x output_binary || echo fail
rm -f output_binary
