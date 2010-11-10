#!/bin/sh
#Input is not correct ruby source. Aborting.
echo ")\")this isn't ruby" | rubyc -
test -f output.c || echo fail
