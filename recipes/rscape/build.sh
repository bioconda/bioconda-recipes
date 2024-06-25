#!/usr/bin/env bash

set -xe

# use newer config.guess and config.sub that support linux-aarch64
cp ${RECIPE_DIR}/config.* .

cp ${RECIPE_DIR}/config.* lib/R2R/R2R-current/

./configure --disable-avx512 --prefix=$PREFIX

make V=1 -j ${CPU_COUNT}
make install
