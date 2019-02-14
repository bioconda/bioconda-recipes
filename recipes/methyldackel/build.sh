#!/bin/bash

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"

export LDFLAGS="-L${PREFIX}/lib"
export CPPFLAGS="-I${PREFIX}/include"
export CFLAGS="-I${PREFIX}/include"

export C_INCLUDE_PATH=$PREFIX/include
cd htslib && make Makefile CC=$CC OPTS="-I$PREFIX/include -L$PREFIX/lib -Wall -g -O3 -pthread" && cd ..
make CC=$CC OPTS="-I$PREFIX/include -L$PREFIX/lib -Wall -g -O3 -pthread"
make install prefix=$PREFIX/bin
