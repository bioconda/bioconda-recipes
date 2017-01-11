#!/bin/sh




set -x -e

export CC=${PREFIX}/bin/gcc
export CXX=${PREFIX}/bin/g++


cd source
make boost-fix=1
mkdir -p $PREFIX/bin
cp spingo spindex $PREFIX/bin
cp ../dist/*.py $PREFIX/bin
chmod a+x $PREFIX/bin/*.py
