#!/bin/bash

mkdir -p "${PREFIX}/bin"
cd bin

binaries="\
sak \
"

for i in ${binaries}; do
  install -v -m 755 $SRC_DIR/bin/$i "${PREFIX}/bin";
done
