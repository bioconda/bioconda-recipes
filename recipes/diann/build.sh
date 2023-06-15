#!/bin/bash

export LDFLAGS="-L${PREFIX}/bin"

mkdir -p $PREFIX/bin

tar xvf data.tar.gz

DIANN_PATH=$(find . -type f -executable | grep -P "diann-[^/]*$")
DIANN_DIR=$(dirname $DIANN_PATH)

# symlink from libgomp-52f2fd74.so.1 to libgomp.so.1
ln -s $PREFIX/bin/libgomp-52f2fd74.so.1 /lib64/libgomp.so.1

cp -R $DIANN_DIR/* $PREFIX/bin/

chmod +x $PREFIX/bin/diann-1.8.1