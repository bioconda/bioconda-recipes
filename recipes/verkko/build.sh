#!/bin/bash

# fail on all errors
set -e


cd $SRC_DIR/src
git submodule init
git submodule update
make clean && make -j$CPU_COUNT
cd ..

mkdir -p "$PREFIX/bin"
cp -r bin/* $PREFIX/bin/
cp -r lib/* $PREFIX/lib/
