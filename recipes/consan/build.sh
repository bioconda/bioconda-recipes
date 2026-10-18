#!/bin/bash

mkdir -p $PREFIX/bin

rm -rf src/squid/libsquid.a
cd src
make clean
cd ..

make CC="$CC" CFLAGS="$CFLAGS -O3 -fcommon -Wno-implicit-function-declaration -Wno-implicit-int -Wno-pointer-to-int-cast -Wno-header-guard -Wno-deprecated-non-prototype" -j"${CPU_COUNT}"
make install

install -v -m 0755 src/boot/bstats $PREFIX/bin
install -v -m 0755 src/utilities/comppair src/utilities/pModel $PREFIX/bin
install -v -m 0755 src/conus-1.1/conus_compare src/conus-1.1/conus_train $PREFIX/bin
install -v -m 0755 src/scompare src/sfold src/strain_ml $PREFIX/bin
