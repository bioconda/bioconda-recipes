#!/bin/bash

CXXFLAGS="-O3 -DNDEBUG" CPPFLAGS="-I$CONDA_PREFIX/include $CPPFLAGS" LDFLAGS="-L$CONDA_PREFIX/lib -Wl,-rpath,$PREFIX/lib $LDFLAGS" ./configure --prefix=$PREFIX
make
# make check # Fails on macosx
make install
