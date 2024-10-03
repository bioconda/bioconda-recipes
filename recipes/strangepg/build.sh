#!/bin/bash -eu

set -xe

export CFLAGS="$CFLAGS -I${PREFIX}/include"
export LDFLAGS="$LDFLAGS -ldl -lpthread"
make -j ${CPU_COUNT} install
