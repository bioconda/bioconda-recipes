#!/bin/bash

CXXFLAGS="-O3 -g" CPPFLAGS="-I$PREFIX/include $CPPFLAGS" LDFLAGS="-L$PREFIX/lib $LDFLAGS" ./configure --prefix=$PREFIX
make
make install

