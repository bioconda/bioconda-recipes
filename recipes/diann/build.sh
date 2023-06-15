#!/bin/bash

mkdir -p $PREFIX/bin

tar xvf data.tar.gz

DIANN_PATH=$(find . -type f -executable | grep -P "diann-[^/]*$")
DIANN_DIR=$(dirname $DIANN_PATH)

cp -R $DIANN_DIR/* $PREFIX/bin/

mv $PREFIX/bin/libgomp-52f2fd74.so.1 $PREFIX/bin/libgomp.so.1

chmod +x $PREFIX/bin/diann-1.8.1