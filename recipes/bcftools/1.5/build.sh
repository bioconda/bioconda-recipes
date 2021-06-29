#!/bin/sh

export CPPFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"

cd htslib*
./configure --prefix=$PREFIX --enable-libcurl CPPFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib"
make
cd ..

./configure --prefix=$PREFIX --enable-libcurl --enable-libgsl CPPFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib"
make prefix=$PREFIX CPPFLAGS=$CPPFLAGS LDFLAGS=$LDFLAGS
make prefix=$PREFIX CPPFLAGS=$CPPFLAGS LDFLAGS=$LDFLAGS plugins install
