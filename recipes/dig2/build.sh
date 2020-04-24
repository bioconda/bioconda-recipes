#!/bin/bash
gcc -O3 -o dig2 dig2.c -lm
mkdir -p $PREFIX/bin
cp $SRC_DIR/dig2 $PREFIX/bin
chmod +x $PREFIX/bin/dig2