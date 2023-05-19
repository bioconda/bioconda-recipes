#!/bin/sh
set -x -e

mkdir -p ${PREFIX}/bin

cd src/
make CC=$CC
make install
cd ..
cp bin/* ${PREFIX}/bin
