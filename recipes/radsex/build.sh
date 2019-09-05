#!/bin/bash
pushd include/bwa
make CC=$CC
popd
make CC=$CXX CFLAGS="$CXXFLAGS" LDFLAGS="$LDFLAGS -pthread -static-libstdc++ -lz"
mkdir -p $PREFIX/bin/
cp bin/radsex $PREFIX/bin/
