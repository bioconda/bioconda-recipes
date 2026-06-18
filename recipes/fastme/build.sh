#!/bin/bash

set -xe

export M4=${BUILD_PREFIX}/bin/m4
autoreconf -ifv
./configure --prefix=${PREFIX}
make -j ${CPU_COUNT}
make install
