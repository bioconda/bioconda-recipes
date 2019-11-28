#!/bin/bash
make
mkdir -p $PREFIX/bin
cp $SRC_DIR/mmr $PREFIX/bin
chmod +x $PREFIX/bin/mmr