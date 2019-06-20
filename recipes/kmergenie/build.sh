#!/bin/sh
set -x -e

#export GCC=${PREFIX}/bin/gcc
#export CXX=${PREFIX}/bin/g++

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"

export LDFLAGS="-L${PREFIX}/lib"
export CXXFLAGS="-I$PREFIX/include"
export CPPFLAGS="-I${PREFIX}/include"
export LC_ALL=C

mkdir -p $PREFIX/bin

sed -i.bak 's/print sys.hexversion>=0x02050000/print(sys.hexversion>=0x02050000)/' makefile

make

sed -i.bak 's/third_party\.//g' scripts/*
sed -i.bak 's/third_party\.//g' kmergenie
sed -i.bak 's/scripts\///g' kmergenie

cp scripts/* $PREFIX/bin
cp third_party/* $PREFIX/bin
cp specialk $PREFIX/bin
cp kmergenie $PREFIX/bin
cp wrapper.py $PREFIX/bin
