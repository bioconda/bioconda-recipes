#!/bin/bash
set -ex

pushd src
make clean && make -j$CPU_COUNT
popd

mkdir -p "$PREFIX/bin"
cp -rf bin/* $PREFIX/bin/
cp -rf lib/* $PREFIX/lib/
