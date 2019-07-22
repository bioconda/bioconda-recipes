#!/bin/bash

export CPATH="${PREFIX}/include"

make
make install
mkdir -p ${PREFIX}
rsync -av ${SRC_DIR}/bin/ ${PREFIX}/bin
