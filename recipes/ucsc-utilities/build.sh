#! /bin/bash

pushd $SRC_DIR
mkdir -p $PREFIX/bin
rsync -aP $PREFIX/include/openssl $SRC_DIR/kent/src/inc/
make
rsync -aP bin/ $PREFIX/bin/
