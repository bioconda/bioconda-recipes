#!/bin/bash
export CPATH=${PREFIX}/include
make with-sse4=no
mkdir -p ${PREFIX}/bin
cp -f mrsfast ${PREFIX}/bin
./mrsfast --help
