#!/bin/bash

set -e -x -o pipefail

binaries="\
mvicuna \
"

mkdir -p $PREFIX/bin/

cd $SRC_DIR/mvicuna/src
make    

if [ "$(uname)" == "Darwin" ]; then
    echo "Copying in *.dylib for OSX"
    mkdir -p $PREFIX/lib/
    cp $SRC_DIR/mvicuna/MacOSX/*.dylib $PREFIX/lib
fi
for i in $binaries; do cp $SRC_DIR/mvicuna/bin/$i $PREFIX/bin/ && chmod +x $PREFIX/bin/$i; done