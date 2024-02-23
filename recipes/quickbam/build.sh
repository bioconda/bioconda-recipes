#!/bin/bash
set -x
mv ${RECIPE_DIR}/instrument.h src/quickbam/
./configure --prefix=$PREFIX
make
make install
cp -r src/quickbam/instrument.h $PREFIX/include/quickbam/
