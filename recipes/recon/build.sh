#!/bin/sh
set -x -e

cd src/
make
make install
cd ..
cp bin/* ${PREFIX}/bin
