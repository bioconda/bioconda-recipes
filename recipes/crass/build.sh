#!/bin/bash

export LDFLAGS=-L${CONDA_PREFIX}/lib
./autogen.sh
./configure --prefix=${PREFIX} --with-xerces=${CONDA_PREFIX}
make
make install
