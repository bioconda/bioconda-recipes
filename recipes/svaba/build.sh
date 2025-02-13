#!/bin/bash
set -eu -o pipefail

echo "#######################"
echo "### DEBUGGING START ###"
echo "#######################"

find . -name hts.h

echo "#####################"
echo "### DEBUGGING END ###"
echo "#####################"

cmake -DHTSLIB_DIR=htslib
make CC=${CC} CXX=${CXX} CFLAGS="-fcommon ${CFLAGS} -L${PREFIX}/lib" CXXFLAGS="-fcommon ${CXXFLAGS} -UNDEBUG -L${PREFIX}/lib" LDFLAGS="${LDFLAGS}"

mkdir -p ${PREFIX}/bin
cp bin/svaba ${PREFIX}/bin/
