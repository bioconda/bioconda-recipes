#!/bin/bash

mkdir -p $PREFIX/bin

cd $SRC_DIR
if [ "$(uname)" == "Darwin" ]; then
    set -x
    otool -L ./guppy
    otool -L ./pplacer
    otool -L ./rppr
fi
cp guppy pplacer rppr $PREFIX/bin
chmod +x $PREFIX/bin/{guppy,pplacer,rppr}
