#!/bin/bash
set -ex

cmake -DCMAKE_INSTALL_PREFIX=${PREFIX} -DCMAKE_PREFIX_PATH=${PREFIX} -DCMAKE_INSTALL_LIBDIR=${PREFIX}/lib .
make

# Install
mkdir $PREFIX/bin
cp Bandage $PREFIX/bin
