#!/bin/bash

mkdir -p $PREFIX/interop/bin
mkdir -p $PREFIX/bin

mkdir -p build
cd build
cmake -DCMAKE_INSTALL_PREFIX:PATH=$PREFIX/interop ..
make
make install
for FPATH in $(find $PREFIX/interop/bin -maxdepth 1 -mindepth 1 -type f -or -type l); do
    ln -sfvn $FPATH $PREFIX/bin/interop_$(basename $FPATH)
done
