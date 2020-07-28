#!/bin/bash

export LDFLAGS="-L${PREFIX}/lib"

mkdir -p ${PREFIX}/bin

make
make install BIN_INSTALL=${PREFIX}/bin