#!/bin/bash
gcc -o compareMS2 compareMS2.c -lm
mkdir -p $PREFIX/bin
cp compareMS2 $PREFIX/bin/
chmod +x $PREFIX/bin/compareMS2