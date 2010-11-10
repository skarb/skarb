#!/bin/sh
echo puts RUBY_VERSION | rubyc -
./a.out || echo fail
