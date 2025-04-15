#!/bin/bash

set -xe

if [ "$(uname)" == "Darwin" ]; then
    # building the library requires an implementation of basic_stringbuf
    # from the c++ standard library
    # 10.9 seems to be the minimum possible deployment target
    MACOSX_DEPLOYMENT_TARGET=10.9
fi

# use newer config.guess and config.sub that support linux-aarch64
cp ${RECIPE_DIR}/config.* ./config/

./configure --prefix=$PREFIX
make -j ${CPU_COUNT}
make install
