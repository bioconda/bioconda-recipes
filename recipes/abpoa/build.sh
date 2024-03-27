#!/bin/bash

mkdir -p $PREFIX/bin

make INCLUDE="-I$PREFIX/include" CFLAGS="-Wall -O3 -Wno-unused-variable -Wno-unused-function -Wno-misleading-indentation -DUSE_SIMDE -DSIMDE_ENABLE_NATIVE_ALIASES -I$PREFIX/include -L$PREFIX/lib"
