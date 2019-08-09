#!/bin/bash

git clone http://github.com/lh3/wgsim
cd wgsim
gcc -g -O2 -Wall -I${PREFIX}/include -L${PREFIX}/lib -o wgsim wgsim.c -lz -lm

cp wgsim wgsim_eval.pl $PREFIX/bin/

