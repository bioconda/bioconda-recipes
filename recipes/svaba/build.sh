#!/bin/bash
set -eu -o pipefail

echo "### DEBUG START ###"

find .

echo "### DEBUG CMAKE ###"

cmake -DHTSLIB_DIR=htslib/htslib/

echo "### DEBUG MAKE ###"

make CC=${CC} CXX=${CXX} CFLAGS="-fcommon ${CFLAGS} -L${PREFIX}/lib" CXXFLAGS="-fcommon ${CXXFLAGS} -UNDEBUG -L${PREFIX}/lib" LDFLAGS="${LDFLAGS}"

echo "### DEBUG DONE ###"

mkdir -p ${PREFIX}/bin
cp bin/svaba ${PREFIX}/bin/
