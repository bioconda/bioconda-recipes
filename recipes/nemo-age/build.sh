#!/bin/bash

export LDFLAGS="-L${PREFIX}/lib/"

mkdir -p ${PREFIX}/bin/

mkdir -p bin/
make GSL_PATH="${PREFIX}/"
make install BIN_INSTALL=${PREFIX}/bin/
mv ${PREFIX}/bin/nemoage* ${PREFIX}/bin/nemoage
