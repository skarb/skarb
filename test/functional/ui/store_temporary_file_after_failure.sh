#!/bin/sh
#The C compiler failed. Aborting.
export CC=sorry_but_there_is_no_such_compiler
echo puts 1 | rubyc -
test -f output.c || echo fail
rm -f output.c
