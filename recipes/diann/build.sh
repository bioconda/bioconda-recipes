#!/bin/bash

mkdir -p $PREFIX/bin

tar xvf data.tar.gz

DIANN_PATH=$(find . -type f -executable -print | grep diann)
DIANN_DIR=$(dirname $DIANN_PATH)

cp -R $DIANN_DIR/* $PREFIX/bin/

chmod +x $PREFIX/bin/diann-1.8.1