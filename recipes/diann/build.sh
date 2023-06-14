#!/bin/bash

mkdir -p $PREFIX/bin

tar xvf data.tar.gz

DIANN_PATH=$(find . -type f -executable -print | grep diann)
DIANN_DIR=$(dirname $DIANN_PATH)

find $DIANN_DIR -type f -exec cp {} $PREFIX/bin/ \;

ln -s ${PREFIX}/bin/libgomp.so.1 ${$DIANN_PATH}/libgomp-52f2fd74.so.1

chmod +x $PREFIX/bin/diann-1.8.1