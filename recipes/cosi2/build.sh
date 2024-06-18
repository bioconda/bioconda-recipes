#!/bin/bash

set -xe

# use newer config.guess and config.sub that support linux-aarch64
cp ${RECIPE_DIR}/config.* ./build-aux/
cp ${RECIPE_DIR}/config.* ./devel/miscutil/build-aux/

export CPPFLAGS="-I${PREFIX}/include"
export LDFLAGS="-L${PREFIX}/lib"

./configure --prefix=$PREFIX
make -j ${CPU_COUNT}
make install