#!/bin/bash
export CPATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib
gcc -o msalign2 base64.c ramp.c msalign2.c -I. -lgd -lm -lz -std=gnu99
cp msalign2 $PREFIX/bin/
chmod +x $PREFIX/bin/msalign2