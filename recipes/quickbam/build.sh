#!/bin/bash
set -x
mv ${RECIPE_DIR}/instrument.h src/quickbam/
./configure --prefix=$PREFIX
make
make install
