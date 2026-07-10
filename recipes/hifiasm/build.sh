#!/bin/bash

mkdir -p $PREFIX/bin

ARCH_OPTS=""
case $(uname -m) in
    x86_64)
        ARCH_OPTS="-msse4.2 -mpopcnt"
        ;;
    *)
        ;;
esac

sed -i.bak 's/CXXFLAGS=.*//' Makefile
rm -rf *.bak
make INCLUDES="-I$PREFIX/include" CXXFLAGS="${CXXFLAGS} -L$PREFIX/lib -g -O3 ${ARCH_OPTS} -fomit-frame-pointer -Wall" CC="${CC}" "CXX=${CXX}"
install -v -m 0755 hifiasm $PREFIX/bin
