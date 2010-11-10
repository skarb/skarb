#!/bin/sh
rubyc uitester.rb || echo fail
./a.out || echo error!
