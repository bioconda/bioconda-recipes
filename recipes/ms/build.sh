#!/bin/bash

gcc -O3 -o ms ms.c streec.c rand1.c -lm
gcc -O3 -o sample_stats sample_stats.c tajd.c -lm

mkdir -p $PREFIX/bin
cp ms $PREFIX/bin
cp sample_stats $PREFIX/bin
