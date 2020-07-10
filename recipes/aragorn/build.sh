#!/bin/sh
"${CXX}" -O3 -ffast-math -finline-functions -o aragorn aragorn1.2.38.c
mkdir -p $PREFIX/bin
mv aragorn $PREFIX/bin
