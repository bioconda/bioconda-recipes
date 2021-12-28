#!/bin/bash
set -ex
mkdir -p $PREFIX/bin

# build FastTree
$CC $CFLAGS $LDFLAGS -Wall -O3 -DUSE_DOUBLE -funroll-loops $SRC_DIR/FastTree-2.1.10.c -lm -o $PREFIX/bin/FastTree
chmod +x $PREFIX/bin/FastTree
# some OS are not case-sensitive (macOS, by default), ignore the copy error there
cp -f -- $PREFIX/bin/FastTree $PREFIX/bin/fasttree || true

# Build FastTreeMP
$CC $CFLAGS $LDFLAGS -Wall -DOPENMP -fopenmp -O3 -DUSE_DOUBLE -funroll-loops $SRC_DIR/FastTree-2.1.10.c -lm -o $PREFIX/bin/FastTreeMP
chmod +x $PREFIX/bin/FastTreeMP
