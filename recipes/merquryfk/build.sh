#!/bin/bash

if [ "$(uname)" == "Darwin" ]; then
     export LDFLAGS="${LDFLAGS} -headerpad_max_install_names"
fi

export LDFLAGS="$LDFLAGS -L$PREFIX/lib"
export CPATH=${PREFIX}/include

make
mkdir -p $PREFIX/bin

cp HAPmaker  $PREFIX/bin
cp ASMplot $PREFIX/bin
cp CNplot $PREFIX/bin
cp HAPplot $PREFIX/bin
cp MerquryFK $PREFIX/bin
cp KatComp $PREFIX/bin
cp KatGC $PREFIX/bin
cp PloidyPlot $PREFIX/bin
