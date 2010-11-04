#!/bin/sh
prog=`shift 1`
$prog $* && $prog $*
