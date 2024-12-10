#!/bin/bash

mkdir -p $PREFIX/bin

rm -rf src/squid/libsquid.a
cd src
make clean
cd ..

make CC="$CC" CFLAGS="$CFLAGS -O3 -Wno-implicit-function-declaration -fcommon -Wno-implicit-int" -j"${CPU_COUNT}"
make install

binaries="\
bstats \
comppair \
conus_compare   \
conus_train   \
pModel   \
scompare  \
sfold  \
strain_ml \
"

for i in $binaries; do install -v -m 0755 bin/$i $PREFIX/bin; done
