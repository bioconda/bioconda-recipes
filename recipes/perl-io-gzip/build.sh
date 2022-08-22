#!/bin/bash

export CPATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib
export LD_LIBRARY_PATH=${PREFIX}/lib

perl Makefile.PL INSTALLDIRS=site libs="-L$PREFIX/lib -lz"
make libs="-L$PREFIX/lib -lz"
make test libs="-L$PREFIX/lib -lz"
make install libs="-L$PREFIX/lib -lz"
