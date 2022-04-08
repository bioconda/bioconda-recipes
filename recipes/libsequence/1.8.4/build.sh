#!/bin/bash

CXXFLAGS="${CXXFLAGS} -O3 -DNDEBUG" ./configure --prefix=$PREFIX
make
# make check # Fails on macosx
make install
