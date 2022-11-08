#!/bin/bash

export LDFLAGS="-L${PREFIX}/lib"
mkdir build; cd build
cmake -DCMAKE_INSTALL_PREFIX=${PREFIX} ..
make
make install
