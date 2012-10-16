#!/bin/sh
#The C compiler failed. Aborting.
export CC=sorry_but_there_is_no_such_compiler
echo 1 | skarb -
test -f output.c || echo fail
rm -f output.c
