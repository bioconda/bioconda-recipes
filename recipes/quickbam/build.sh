#!/bin/bash
set -x
mv ${RECIPE_DIR}/instrument.h src/quickbam/
cp -r src/quickbam $PREFIX/include
./configure --prefix=$PREFIX
make
make install
