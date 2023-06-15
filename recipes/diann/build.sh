#!/bin/bash

export LDFLAGS="-L${PREFIX}/bin"

mkdir -p $PREFIX/bin

tar xvf data.tar.gz

DIANN_PATH=$(find . -type f -executable | grep -P "diann-[^/]*$")
DIANN_DIR=$(dirname $DIANN_PATH)

cp -R $DIANN_DIR/* $PREFIX/bin/

chmod +x $PREFIX/bin/diann-1.8.1