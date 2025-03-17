#!/usr/bin/env bash

set -xe

wget https://github.com/simd-everywhere/simde/archive/refs/tags/v0.8.2.tar.gz
tar zxvf v0.8.2.tar.gz

export CFLAGS="${CFLAGS} -I simd-0.8.2/simde -Wall -O2"

make CFLAGS=${CFLAGS} PREFIX={$PREFIX} CC=${CC}
make install 
# Install as plink
