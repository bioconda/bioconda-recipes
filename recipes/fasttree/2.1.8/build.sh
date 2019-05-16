#!/bin/bash


mkdir -p $PREFIX/bin

# build FastTree
gcc -O3 -DUSE_DOUBLE -finline-functions -funroll-loops -Wall -o FastTree $SRC_DIR/FastTree-2.1.8.c -lm
chmod +x FastTree
cp ./FastTree $PREFIX/bin/fasttree


# Build FastTreeMP on Linux
if [ "$(uname)" == "Linux" ]; then
    gcc -DOPENMP -fopenmp -O3 -DUSE_DOUBLE -finline-functions -funroll-loops -Wall -o FastTreeMP $SRC_DIR/FastTree-2.1.8.c -lm
    chmod +x FastTreeMP
    mv -v ./FastTree* $PREFIX/bin
fi
