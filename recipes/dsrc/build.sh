#!/bin/sh

yum install glibc-static -y

sed -i -e  "s/\$(CXXFLAGS)/\$(CXXFLAGS) \$(CFLAGS)/g" src/Makefile
sed -i -e "s/-lpthread/-lpthread -lrt/g" Makefile
export CFLAGS=" -I${PREFIX}/include -L${PREFIX}/lib"

export CC=${PREFIX}/bin/gcc
export CXX=${PREFIX}/bin/g++

make
make bin
cp bin/dsrc $PREFIX/bin

