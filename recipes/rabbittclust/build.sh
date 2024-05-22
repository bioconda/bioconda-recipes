#!/bin/bash

export CC=${CC:-gcc}
export CXX=${CXX:-g++}

./install.sh

mkdir -p $PREFIX/bin
cp clust-mst $PREFIX/bin/
cp clust-greedy $PREFIX/bin/

#export LIBRARY_DIRS="$LIBRARY_DIRS $PREFIX/lib"

#make BIOCONDA=1
#make install

