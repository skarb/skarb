#!/bin/sh
#args_have_been_passed
#acts_as_cc
export CFLAGS=this_is_for_testing_purposes
export CC=$srcdir/cc
echo 0 | rubyc -
rm -f a.out
