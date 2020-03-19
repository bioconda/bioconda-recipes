#!/bin/bash

mkdir -p $PREFIX/bin

make INCLUDE="-I$BUILD_PREFIX/include" CFLAGS="-Wall -O3 -Wno-unused-variable -Wno-unused-but-set-variable -Wno-unused-function -Wno-misleading-indentation -L$BUILD_PREFIX/lib"

cp bin/TideHunter $PREFIX/bin
