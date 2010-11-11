#!/bin/sh
echo puts RUBY_VERSION | rubyc - || echo fail
./a.out || echo fail
rm -f a.out
