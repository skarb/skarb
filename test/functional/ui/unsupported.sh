#!/bin/sh
#Input contains unsupported Ruby instruction in line 1. Aborting.
echo 'begin; puts 4; rescue Exception; puts 5; end' | rubyc - && echo fail
