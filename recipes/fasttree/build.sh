#!/bin/bash

mkdir -p $PREFIX/bin

# build FastTree
$CC $CFLAGS -O3 -DUSE_DOUBLE -finline-functions -funroll-loops -Wall -o FastTree $SRC_DIR/FastTree-2.1.10.c -lm
chmod +x FastTree
cp ./FastTree $PREFIX/bin/fasttree

# Build FastTreeMP on Linux
if [ "$(uname)" == "Linux" ]; then
    $CC $CFLAGS -DOPENMP -fopenmp -O3 -DUSE_DOUBLE -finline-functions -funroll-loops -Wall -o FastTreeMP $SRC_DIR/FastTree-2.1.10.c -lm
    chmod +x FastTreeMP
    mv -v ./FastTree* $PREFIX/bin
fi
