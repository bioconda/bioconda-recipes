#!/bin/bash

# This is needed to pick up the zlib libraries for some reason
export LDFLAGS=-L${CONDA_PREFIX}/lib
./autogen.sh
./configure --prefix=${PREFIX} --with-xerces=${CONDA_PREFIX}
make
make install
