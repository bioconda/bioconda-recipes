#!/bin/bash

mkdir -pv $PREFIX/bin

# download data files
curl http://www.bio8.cs.hku.hk/sensv/data.tar.gz --output data.tar.gz
tar -xf data.tar.gz

cp -rv src modules data $PREFIX/bin
cp Makefile sensv *.ini $PREFIX/bin/

cd $PREFIX/bin/ && make CC=$CC INCLUDES="-I$PREFIX/include" CFLAGS="-g -Wall -O2 -Wc++-compat -L$PREFIX/lib" && cd -
