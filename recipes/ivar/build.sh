#!/bin/bash

export CPATH=${PREFIX}/include

./autogen.sh
./configure --prefix=$PREFIX --with-hts=$PREFIX/include/htslib
make
make check
make install
