#!/usr/bin/env bash

set -xe

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

make -j"${CPU_COUNT}"
make install
