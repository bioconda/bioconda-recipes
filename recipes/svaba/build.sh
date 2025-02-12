#!/bin/bash
set -eu -o pipefail

echo "###################"
echo "### DEBUG START ###"
echo "###################"

find . | grep configure

echo "#################"
echo "### DEBUG END ###"
echo "#################"

cmake
make CC=${CC} CXX=${CXX} CFLAGS="-fcommon ${CFLAGS} -L${PREFIX}/lib" CXXFLAGS="-fcommon ${CXXFLAGS} -UNDEBUG -L${PREFIX}/lib" LDFLAGS="${LDFLAGS}"

mkdir -p ${PREFIX}/bin
cp bin/svaba ${PREFIX}/bin/
