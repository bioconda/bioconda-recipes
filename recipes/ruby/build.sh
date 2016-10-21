#!/bin/bash

export DYLD_FALLBACK_LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"

./configure --prefix=$PREFIX --disable-install-doc --with-zlib-include=$PREFIX/include --with-zlib-lib=$PREFIX/lib --enable-load-relative --with-openssl-dir=$PREFIX CPPFLAGS="-fgnu89-inline"
make
make install
