#!/bin/bash

# use newer config.guess and config.sub that support linux-aarch64
cp ${RECIPE_DIR}/config.* .

mkdir -p ${PREFIX}
./configure --prefix=$PREFIX
make install
ln -s ${PREFIX}/bin/clustalw2 ${PREFIX}/bin/clustalw
