#!/bin/bash

set -xe

export CPPFLAGS="-I${PREFIX}/include"
export LDFLAGS="-L${PREFIX}/lib"

./configure --prefix=$PREFIX
make -j ${CPU_COUNT}
make install