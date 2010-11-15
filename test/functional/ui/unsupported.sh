#!/bin/sh
#Input contains unsupported Ruby instructions. Aborting.
echo 'begin; puts 4; rescue Exception; puts 5; end' | rubyc - && echo fail
