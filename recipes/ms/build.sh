#!/bin/bash

gcc -O3 -o ms ms.c streec.c rand1.c -lm

mkdir -p $PREFIX/bin
cp ms $PREFIX/bin
