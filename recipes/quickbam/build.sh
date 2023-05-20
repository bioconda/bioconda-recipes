#!/bin/bash
set -x
mv ${SRC_DIR}/instrument.h src/quickbam/
./configure --prefix=$PREFIX
make
make install
