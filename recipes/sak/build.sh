#!/bin/bash

cd bin

binaries="\
sak \
"

mkdir -p $PREFIX/bin

for i in ${binaries}; do
  install -v -m 755 $SRC_DIR/bin/$i "${PREFIX/bin}";
done
