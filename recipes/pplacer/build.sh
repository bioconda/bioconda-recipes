#!/bin/bash

mkdir -p $PREFIX/bin

cd $SRC_DIR/bin
cp guppy pplacer rppr $PREFIX/bin
chmod +x $PREFIX/bin/{guppy,pplacer,rppr}
