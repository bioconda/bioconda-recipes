#!/bin/bash

export LDFLAGS="-L${PREFIX}/lib"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$PREFIX/lib/"

mkdir -p $PREFIX/bin

tar xvf data.tar.gz

DIANN_PATH=$(find . -type f -executable | grep -P "diann-[^/]*$")
DIANN_DIR=$(dirname $DIANN_PATH)

cp -R $DIANN_DIR/* $PREFIX/bin/

# symlink from libgomp-52f2fd74.so.1 to libgomp.so.1
ln -s $PREFIX/lib/libgomp.so.1.0.0 $PREFIX/bin/libgomp.so.1

chmod +x $PREFIX/bin/diann-1.8.1
chmod +rx $PREFIX/bin/libgomp.so.1
