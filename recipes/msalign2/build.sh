#!/bin/bash
export C_INCLUDE_PATH=${PREFIX}/include
gcc -o msalign2 base64.c ramp.c msalign2.c -I. -lgd -lm -lz -std=gnu99

cp msalign2 $PREFIX/bin/
chmod +x $PREFIX/bin/msalign2