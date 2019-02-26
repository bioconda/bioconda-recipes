#!/bin/bash
export C_INCLUDE_PATH="$PREFIX/include"
cd htslib && make CC=$CC OPTS="-I$PREFIX/include -L$PREFIX/lib -Wall -g -O3 -pthread" LDFLAGS="-L$PREFIX/lib" && cd ..
export LIBRARY_PATH="$PREFIX/lib"
export LIBRARY_PATH="$PREFIX/lib"
make install CC=$CC OPTS="-I$PREFIX/include -L$PREFIX/lib -Wall -g -O3 -pthread" prefix=$PREFIX/bin
