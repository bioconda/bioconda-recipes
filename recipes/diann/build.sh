#!/bin/bash

export LDFLAGS="-L${PREFIX}/lib"
export LD_LIBRARY_PATH=$PREFIX/lib:$LD_LIBRARY_PATH

mkdir -p $PREFIX/bin

tar xvf data.tar.gz

DIANN_PATH=$(find . -type f -executable | grep -P "diann-[^/]*$")
DIANN_DIR=$(dirname $DIANN_PATH)

mv -R $DIANN_DIR/diann-1.8.1 $PREFIX/bin/
cp -R $DIANN_DIR/* $PREFIX/lib/

chmod +x $PREFIX/bin/diann-1.8.1
