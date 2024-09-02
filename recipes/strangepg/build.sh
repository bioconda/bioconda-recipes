#!/bin/bash -eu
export CFLAGS="$CFLAGS -I${PREFIX}/include"
export LDFLAGS="$LDFLAGS -ldl -lpthread"
make -j install
