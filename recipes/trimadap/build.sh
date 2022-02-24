#!/bin/bash

mkdir -p $PREFIX/bin

make CC="$CC" CFLAGS="-g -Wall -O2 -Wno-unused-function -I$PREFIX/include -L$PREFIX/lib"

mv trimadap-mt $PREFIX/bin
