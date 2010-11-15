#!/bin/sh
#acts_as_cc
#acts_as_cc
ruby_fullpath=`which $RUBY`
export PATH="$srcdir:`dirname $ruby_fullpath`:$PATH"
echo 0 | rubyc - || echo fail
