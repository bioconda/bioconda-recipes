#!/bin/bash -euo

export LDFLAGS="$LDFLAGS -L$PREFIX/lib"
export CPATH=${PREFIX}/include

make CC=${CC} LIBS="-L ${PREFIX}/lib -lz"
make -C paf2gfa CC=${CC} LIBS="-L ${PREFIX}/lib -lz"

mkdir -p ${PREFIX}/bin/
cp ./gfatools ${PREFIX}/bin/
cp ./paf2gfa/paf2gfa ${PREFIX}/bin/
