#!/bin/sh
set -x -e

cd src/
make CC=$CC
make install CC=$CC
cd ..
cp bin/* ${PREFIX}/bin
