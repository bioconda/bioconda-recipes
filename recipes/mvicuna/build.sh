#!/bin/bash

set -e -x -o pipefail

binaries="\
mvicuna \
"

mkdir -p $PREFIX/bin/

if [ "$(uname)" == "Darwin" ]; then
    echo "Copying in *.dylib for OSX"
    mkdir -p $PREFIX/lib/
    cp $SRC_DIR/mvicuna/MacOSX/*.dylib $PREFIX/lib
    cp $SRC_DIR/mvicuna/MacOSX/mvicuna $PREFIX/bin
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    echo "Platform: Linux"

    cd $SRC_DIR/mvicuna/src
    make    

    for i in $binaries; do cp $SRC_DIR/mvicuna/bin/$i $PREFIX/bin/; done
fi

chmod +x $PREFIX/bin/*