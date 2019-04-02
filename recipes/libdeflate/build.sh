#!/bin/bash

export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

if [ `uname` == Darwin ]; then
  sed -i.bak -e 's/.so.$(SOVERSION)/.$(SOVERSION).dylib' \
    -e 's/-Wl,-soname=libdeflate$(SHARED_LIB_SUFFIX)/-install_name libdeflate$(SHARED_LIB_SUFFIX)/' \
    Makefile
fi

make V=1
mkdir -p $PREFIX/bin
mkdir -p $PREFIX/lib
mkdir -p $PREFIX/include
# Note to the wise: we're just copying over the library part of libdeflate
# Excluding the "gzip" replacements, which would clobber the traditional zlib packages if installed.
cp libdeflate.so $PREFIX/lib/
cp libdeflate.h $PREFIX/include/
