#!/bin/bash

if [[ $OSTYPE == "linux-gnu" ]]; then
    export LIBS="-lrt -lm"
fi
touch configure.ac aclocal.m4 configure Makefile.* */Makefile.* */*/Makefile.*
./configure CC=$CC CXX=$CXX --prefix=$PREFIX --with-mangling=aligned_alloc:__aligned_alloc --disable-tls
make
make install
