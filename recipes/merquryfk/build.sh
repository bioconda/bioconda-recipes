#!/bin/bash

set -xe

export LDFLAGS="$LDFLAGS -L$PREFIX/lib"
export CPATH=${PREFIX}/include

make -j"${CPU_COUNT}"
mkdir -p $PREFIX/bin

cp HAPmaker  $PREFIX/bin
cp ASMplot $PREFIX/bin
cp CNplot $PREFIX/bin
cp HAPplot $PREFIX/bin
cp MerquryFK $PREFIX/bin
cp KatComp $PREFIX/bin
cp KatGC $PREFIX/bin
cp PloidyPlot $PREFIX/bin
