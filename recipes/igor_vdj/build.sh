#!/bin/bash

export LIBS="-lrt -lm"
#sed -i.bak -e "s:libs/jemalloc::g" configure
#rm -rf libs/jemalloc
#sed -i.bak -e "s:jemalloc::" libs/Makefile.am
#sed -i.bak -e "s:jemalloc::" libs/Makefile.in

touch configure.ac aclocal.m4 configure Makefile.* */Makefile.* */*/Makefile.*
./configure CC=$CC CXX=$CXX --prefix=$PREFIX --with-mangling=aligned_alloc:__aligned_alloc --disable-tls
make
make install
