#!/bin/sh
#Usage: skarb [options] input
#Options:
#    -o FILE                          Place the output into FILE
#    -C                               Output the C code and exit
#    -c                               Don't link, only compile
#        --math_inline                Use C operators in math expressions
#        --stack_alloc                Use stack allocation for local objects
#        --object_reuse               Reuse memory of dead local objects
#    -h                               Show this message
skarb
