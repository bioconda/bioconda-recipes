#!/bin/bash

INSTALL_DIR=$PREFIX/lib/phyloFlash

mkdir -p ${PREFIX}/bin
mkdir -p $INSTALL_DIR
cp -av * $INSTALL_DIR
for n in *.{R,pl}; do
    ln -s $INSTALL_DIR/$n $PREFIX/bin/$n
done
