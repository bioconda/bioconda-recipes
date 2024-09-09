#!/bin/bash -euo

mkdir -p $PREFIX/bin

pushd abPOA
make libabpoa INCLUDE="-I$PREFIX/include" CFLAGS="$CFLAGS -O3 -L$PREFIX/lib"
popd

make CFLAGS="-Wall -O3 -Wno-unused-variable -Wno-unused-function -Wno-misleading-indentation -I$PREFIX/include -L$PREFIX/lib"

chmod 0755 bin/TideHunter
cp -f bin/TideHunter $PREFIX/bin
