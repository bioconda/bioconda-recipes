#!/bin/bash
export C_INCLUDE_PATH="$PREFIX/include"
cd htslib && make CC=$CC OPTS="-I$PREFIX/include -L$PREFIX/lib -Wall -g -O3 -pthread" LDFLAGS="-L$PREFIX/lib" && cd ..
make CC=$CC OPTS="-I$PREFIX/include -L$PREFIX/lib -Wall -g -O3 -pthread"
make install prefix=$PREFIX/bin
