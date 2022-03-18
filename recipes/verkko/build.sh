#!/bin/bash
set -e

pushd src
make clean && make -j$CPU_COUNT
popd

mkdir -p "$PREFIX/bin"
cp -r bin/* $PREFIX/bin/
cp -r lib/* $PREFIX/lib/
