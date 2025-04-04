#!/bin/bash

pushd cage_src
make CC="${CXX}" INCLUDES= CFLAGS="${CXXFLAGS} -Wall -O3 -std=c++11" LFLAGS="${LDFLAGS} -lpthread -lsqlite3"
popd
pushd bamdump_src
make CC="${CXX}" INCLUDES="-I${PREFIX}/include/bamtools" CFLAGS="${CXXFLAGS} -Wall -O3 -std=c++11" LFLAGS="${LDFLAGS} -lpthread -lbamtools"
popd

mkdir -p $PREFIX/bin
cp cage_src/cage $PREFIX/bin
cp bamdump_src/bamdump $PREFIX/bin

sed -i.bak 's@#!/anaconda/bin/python@#!/opt/anaconda1anaconda2anaconda3/bin/python@g' scripts/classify.py
cp scripts/classify.py $PREFIX/bin/cage-classify.py

TGT="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
mkdir -p "$TGT"
cp scripts/*.sh $TGT
cp scripts/config_example.txt $TGT
