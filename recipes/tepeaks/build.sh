#!/bin/bash
rm -f TEpeaks *.a
pushd src/htslib-1.2.1_src
make CC=${CC} CFLAGS="$CFLAGS" prefix=${PREFIX} LDFLAGS="$LDFLAGS"
popd

export BOOST_ROOT=${PREFIX}/include
sed -i.bak "s/(const )//g" src/TEToolkit/khash.h
make -f Makefile.LINUX CC=${CXX} prefix=${PREFIX} CFLAGS="$CXXFLAGS" LDFLAGS="$LDFLAGS"
