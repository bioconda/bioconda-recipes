#!/bin/bash

make -j"${CPU_COUNT}" LDFLAGS="${LDFLAGS} -L$( pwd )/lib"
make install
