#!/bin/bash

mkdir -p $PREFIX/bin

$CC -g -Wall -O2 -Wno-unused-function -I$PREFIX/include -L$PREFIX/lib -o trimadap ksw.c trimadap.c -lz -lm

mv trimadap $PREFIX/bin
