#!/bin/bash

export LIBS="-lrt -lm"
./configure CC=$CC CXX=$CXX --prefix=$PREFIX --with-mangling=aligned_alloc:__aligned_alloc --disable-tls
make
make install
