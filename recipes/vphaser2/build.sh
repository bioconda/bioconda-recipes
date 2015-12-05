#!/bin/bash

set -e -x -o pipefail

mkdir -p $PREFIX/bin/

if [ "$(uname)" == "Darwin" ]; then
    echo "Copying in *.dylib for OSX"
    mkdir -p $PREFIX/lib/
    cp $SRC_DIR/V-Phaser-2.0/MacOSX/*.dylib $PREFIX/lib
    cp $SRC_DIR/V-Phaser-2.0/MacOSX/variant_caller $PREFIX/bin
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    echo "Platform: Linux"

    cp $SRC_DIR/V-Phaser-2.0/linux64/variant_caller $PREFIX/bin
fi
chmod +x $PREFIX/bin/variant_caller
ln -s $PREFIX/bin/variant_caller $PREFIX/bin/vphaser2