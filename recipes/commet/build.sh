#!/bin/bash

mkdir -p ${PREFIX}/bin

# installation
make CC=$CXX CFLAGS="$CXXFLAGS -Iinclude -L${PREFIX}/lib ${LDFLAGS}"

# copy binaries and scripts
cp Commet.py ${PREFIX}/bin
cp dendro.R ${PREFIX}/bin
cp heatmap.r ${PREFIX}/bin
cp bin/* ${PREFIX}/bin
