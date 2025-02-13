#!/bin/bash
set -eu -o pipefail

echo "### DEBUGGING A ###"
find . -name configure.ac

cd htslib
autoreconf -i

echo "### DEBUGGING B ###"
find . -name configure.ac

./configure
make
make install
cd ..

cd SeqLib
ln -s ../htslib .
cd ..

cmake -DHTSLIB_DIR=htslib
make CC=${CC} CXX=${CXX} CFLAGS="-fcommon ${CFLAGS} -L${PREFIX}/lib" CXXFLAGS="-fcommon ${CXXFLAGS} -UNDEBUG -L${PREFIX}/lib" LDFLAGS="${LDFLAGS}"

mkdir -p ${PREFIX}/bin
cp bin/svaba ${PREFIX}/bin/
